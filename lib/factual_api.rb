require 'oauth'
require 'json'
require 'uri'
require 'ostruct'

module Factual
  class Api
    API_V3_HOST        = "http://api.v3.factual.com"
    DRIVER_VERSION_TAG = "factual-ruby-driver-1.0"
    PARAM_ALIASES      = { :search => :q }

    # initializers
    # ----------------
    def initialize(key, secret)
      @access_token = OAuth::AccessToken.new(
        OAuth::Consumer.new(key, secret))
    end

    # actions
    # ----------------
    def crosswalk(factual_id, format = :object)
      query = Query.new(self, :crosswalk, "places/crosswalk", { :factual_id => factual_id }, format)

      return query
    end

    def resolve(values, format = :object)
      query = Query.new(self, :resolve, "places/resolve", { :values => values }, format)

      return query
    end

    def table(table_id_or_alias, format = :object)
      query = Query.new(self, :read, "t/#{table_id_or_alias}", Hash.new, format)

      return query
    end

    # requesting
    # ----------------
    def request(path, params)
      url     = "#{API_V3_HOST}/#{path}?#{query_string(params)}"
      headers = {"X-Factual-Lib" => DRIVER_VERSION_TAG}

      return @access_token.get(url, headers)
    end

    private

    def query_string(params)
      arr = []
      params.each do |param, v|
        param_alias = PARAM_ALIASES[param.to_sym] || param.to_sym

        v = v.to_json if v.class == Hash
        arr << "#{param_alias}=#{URI.escape(v.to_s)}"
      end
      return arr.join("&")
    end

  end

  class Query

    # helper functions
    DEFAULT_LIMIT = 20

    VALID_PARAMS = {
      :read      => [ :filters, :search, :geo, :sort, :select, :limit, :offset ],
      :resolve   => [ :values ],
      :crosswalk => [ :factual_id ],
      :facets    => [ :filters, :search, :geo, :limit, :select, :min_count ],
      :schema    => [ ],
      :any       => [ :include_count ]
    }

    attr_accessor :params

    # initializers
    # ----------------
    def initialize(api, action, path, params = nil, format = :object)
      @api    = api
      @action = action
      @path   = path
      @params = params || Hash.new
      @format = format
    end
    
    # helper functions
    # ----------------
    def clone
      new_query = self.class.new(@api, @action, @path, @params.clone, @format)

      return new_query
    end

    def set_param(key, value)
      @params[key] = value
    end

    # attributes, after 'get'
    # ----------------
    def first
      row_data = read_response["data"].first

      if (@format == :json) # or :object
        return row_data
      else
        return Row.new(row_data)
      end
    end

    def rows
      return read_response["data"] if (@format == :json)

      return read_response["data"].collect do |row_data|
        Row.new(row_data)
      end
    end

    def total_count
      read_response["total_row_count"]
    end


    def schema
      unless @schema_response
        @path  += "/schema"
        @schema_response = response(:schema)
      end

      view   = @schema_response["view"]
      fields = view["fields"]

      schema = Table.new(view)
      if schema && fields
        schema.fields = fields.collect do |f|
          Field.new(f)
        end
      end

      return schema
    end

    def facets
      unless @facets_response
        @path  += "/facets"
        @facets_response = response(:facets)
      end
      columns = @facets_response["data"]

      return Facet.new(columns)
    end

    # query builder, returns immutable ojbects
    # ----------------
    VALID_PARAMS.values.flatten.uniq.each do |param|
      define_method(param) do |*args|
        api = self.clone()
        val = (args.length == 1) ? args.first : args.join(',')

        api.set_param(param, val)

        return api
      end
    end
    
    # sugers
    # ----------------
    def sort_desc(*args)
      api = self.clone
      columns = args.collect{ |col|"#{col}:desc" }
      api.set_param(:sort, columns.join(','))

      return api
    end

    def page(page_num, paging_opts = {})
      limit = (paging_opts[:per] || paging_opts["per"]).to_i
      limit = DEFAULT_LIMIT if limit < 1

      page_num = page_num.to_i
      page_num = 1 if page_num < 1
      offset   = (page_num - 1) * limit

      api = self.clone
      api.set_param(:limit, limit)
      api.set_param(:offset, offset)

      return api
    end

    # requesting
    # ----------------
    private

    def read_response
      if @read_response
        return @read_response
      else
        # always include count for reads
        @params[:include_count] = true
        return response(@action || :read)
      end
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

  # response classes
  # ----------------
  class Row < OpenStruct; end
  class Facet < OpenStruct; end
  class Table < OpenStruct; end
  class Field < OpenStruct; end
end
