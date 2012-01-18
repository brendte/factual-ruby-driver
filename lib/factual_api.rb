require 'json'
require 'uri'

module Factual
  class API
    API_V3_HOST        = "http://api.v3.factual.com"
    DRIVER_VERSION_TAG = "factual-ruby-driver-1.0"
    PARAM_ALIASES      = { :search => :q }

    def initialize(access_token)
      @access_token = access_token
    end

    def data(query)
      handle_request(query.action || :read, query.path, query.params)["data"]
    end

    def total_rows(query)
      handle_request(query.action || :read, query.path, query.params)["total_row_count"]
    end

    def schema(query)
      handle_request(:schema, query.path, query.params)["view"]
    end

    private

    def handle_request(action, path, params)
      params[:include_count] = true
      response = make_request(path, params)
      json    = response.body
      payload = JSON.parse(json)

      raise StandardError.new(payload["message"]) unless payload["status"] == "ok"

      payload["response"]
    end

    def make_request(path, params)
      url     = "#{API_V3_HOST}/#{path}?#{query_string(params)}"
      headers = { "X-Factual-Lib" => DRIVER_VERSION_TAG }

      @access_token.get(url, headers)
    end

    def query_string(params)
      query_array = params.keys.inject([]) do |array, key|
        param_alias = PARAM_ALIASES[key.to_sym] || key.to_sym
        value = params[key].class == Hash ? params[key].to_json : params[key].to_s
        array << "#{param_alias}=#{URI.escape(value)}"
      end

      query_array.join("&")
    end
  end

  class Query
    include Enumerable

    DEFAULT_LIMIT = 20
    VALID_PARAMS = {
      :read      => [ :filters, :search, :geo, :sort, :select, :limit, :offset ],
      :resolve   => [ :values ],
      :crosswalk => [ :factual_id ],
      :schema    => [ ],
      :any       => [ :include_count ]
    }

    def initialize(api, action, path, params = {})
      @api = api
      @action = action
      @path = path
      @params = params
      @data = nil
      @total_rows = nil
      @schema = nil
      validate_params
    end

    # Attribute Readers
    [:action, :path, :params].each do |attribute|
      define_method(attribute) do
        instance_variable_get("@#{attribute}").clone
      end
    end

    # Response Methods
    def each(&block)
      all.each { |row| block.call(row) }
    end

    def last
      all.last
    end

    def [](index)
      all[index]
    end

    def all
      (@data ||= @api.data(self)).clone
    end

    def total_rows
      (@total_rows ||= @api.total_rows(self)).clone
    end

    def schema
      unless @schema
        query = Query.new(@api, @action, @path + "/schema", @params)
        @schema = @api.schema(query)
      end

      @schema.clone
    end

    # Query Modifiers
    VALID_PARAMS.values.flatten.uniq.each do |param|
      define_method(param) do |*args|
        value = args.length == 1 ? args.first.strip : args.map(&:strip).join(',')

        new_params = @params.clone
        new_params[param] = value

        Query.new(@api, @action, @path, new_params)
      end
    end

    def sort_desc(*args)
      columns = args.map { |column| "#{column}:desc" }

      new_params = @params.clone
      new_params[:sort] = columns.join(',')

      Query.new(@api, @action, @path, new_params)
    end

    def page(page_number, paging_options = {})
      limit = (paging_options[:per] || paging_options["per"] || DEFAULT_LIMIT).to_i
      limit = DEFAULT_LIMIT if limit < 1

      page_number = page_number.to_i
      page_number = 1 if page_number < 1

      new_params = @params.clone
      new_params[:limit] = limit
      new_params[:offset] = (page_number - 1) * limit

      Query.new(@api, @action, @path, new_params)
    end

    private

    # Validations
    def validate_params
      @params.each do |param, val|
        unless (VALID_PARAMS[@action] + VALID_PARAMS[:any]).include?(param)
          raise StandardError.new("InvalidArgument #{param} for #{@action}")
        end
      end
    end
  end
end
