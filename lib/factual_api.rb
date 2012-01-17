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

    def request(path, params)
      url     = "#{API_V3_HOST}/#{path}?#{query_string(params)}"
      headers = { "X-Factual-Lib" => DRIVER_VERSION_TAG }

      @access_token.get(url, headers)
    end

    private

    def query_string(params)
      arr = []
      params.each do |key, value|
        param_alias = PARAM_ALIASES[key.to_sym] || key.to_sym

        value = value.to_json if value.class == Hash
        arr << "#{param_alias}=#{URI.escape(value.to_s)}"
      end

      arr.join("&")
    end
  end

  class Query
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
    end

    def first
      read_response["data"].first
    end

    def all
      read_response["data"]
    end

    def count
      read_response["total_row_count"]
    end

    def schema
      unless @schema_response
        @path  += "/schema"
        @schema_response = response(:schema)
      end

      @schema_response["view"]
    end

    # Query Modifiers
    VALID_PARAMS.values.flatten.uniq.each do |param|
      define_method("#{param}=") do |*args|
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

    def read_response
      unless @read_response
        @params[:include_count] = true
        @read_response = response(@action || :read)
      end

      @read_response
    end

    def check_params!(action)
      @params.each do |param, val|
        unless (VALID_PARAMS[action] + VALID_PARAMS[:any]).include?(param)
          raise StandardError.new("InvalidArgument #{param} for #{action}")
        end
      end
    end

    def response(action)
      check_params!(action)

      res = @api.request(@path, @params)

      code    = res.code
      json    = res.body
      payload = JSON.parse(json)

      if payload["status"] == "ok"
        return payload["response"]
      else
        raise StandardError.new(payload["message"])
      end
    end
  end
end
