require 'oauth'
require 'json'
require 'uri'
require 'ostruct'

module Factual
  class Api
    API_V3_HOST = "http://api.v3.factual.com"
    DRIVER_VERSION_TAG = "factual-ruby-driver-1.0"

    DEFAULT_LIMIT = 20
    PARAM_ALIASES = { :query => :q }

    VALID_PARAMS = {
      :read      => [ :filters, :query, :geo, :sort, :select, :limit, :offset ],
      :resolve   => [ :values ],
      :crosswalk => [ :factual_id ],
      :facets    => [ :filters, :query, :geo, :limit, :select, :min_count ],
      :any       => [ :include_count ]
    }

    attr_accessor :access_token, :path, :params, :action, :format

    # initializers
    # ----------------
    def initialize(key, secret, format = :object)
      @access_token = OAuth::AccessToken.new(
        OAuth::Consumer.new(key, secret))

      @format = format
      @params = Hash.new
    end
    
    # helper functions
    # ----------------
    def self.clone(api)
      new_api = self.new(nil, nil)

      new_api.access_token = api.access_token
      new_api.path         = api.path
      new_api.action       = api.action
      new_api.format       = api.format
      new_api.params       = api.params.clone

      return new_api
    end

    def set_param(key, value)
      @params[key] = value
    end

    # attributes, after 'get'
    # ----------------
    def first
      row_data = response["data"].first 

      if (@format == :json) # or :hash ?
        return row_data
      else
        return Row.new(row_data)
      end
    end

    def facets
      @path  += "/facets"
      @action = :facets
      columns = response["data"]
      
      return Facet.new(columns)
    end

    def total_count
      response["total_row_count"]
    end

    def rows
      return response["data"] if (@format == :json)

      return response["data"].collect do |row_data|
        Row.new(row_data)
      end
    end

    # query builder, returns immutable ojbects
    # ----------------
    VALID_PARAMS.values.flatten.uniq.each do |param|
      define_method(param) do |*args|
        api = self.class.clone(self)
        val = (args.length == 1) ? args.first : args.join(',')

        api.set_param(param, val)

        return api
      end
    end
    
    # sugers
    # ----------------
    def sort_desc(*args)
      api = self.class.clone(self)
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

      api = self.class.clone(self)
      api.set_param(:limit, limit)
      api.set_param(:offset, offset)

      return api
    end

    # actions
    # ----------------
    def crosswalk(factual_id)
      @path   = "places/crosswalk"
      @action = :crosswalk
      @params = { :factual_id => factual_id }

      return self
    end

    def resolve(values)
      @action = :resolve
      @path   = "places/resolve"
      @params = { :values => values }

      return self
    end

    def table(table_id_or_alias)
      @path   = "t/#{table_id_or_alias}"
      @action = :read

      return self
    end

    private

    # real requesting
    # ----------------
    def response
      return @response if @response
      
      # always include count
      @params[:include_count] = true

      res = request()

      code    = res.code
      json    = res.body
      payload = JSON.parse(json)

      if payload["status"] == "ok"
        @response = payload["response"]
      else
        raise StandardError.new(payload["message"])
      end
      
      return @response
    end

    def request
      url     = "#{API_V3_HOST}/#{@path}?#{query_string}" 
      headers = {"X-Factual-Lib" => DRIVER_VERSION_TAG}

      return @access_token.get(url, headers)
    end

    def query_string()
      arr = []
      @params.each do |param, v|
        unless (VALID_PARAMS[@action] + VALID_PARAMS[:any]).include?(param)
          raise StandardError.new("InvalidArgument #{param} for #{@action}") 
        end
        param_alias = PARAM_ALIASES[param.to_sym] || param.to_sym

        v = v.to_json if v.class == Hash
        arr << "#{param_alias}=#{URI.escape(v.to_s)}"
      end
      return arr.join("&")
    end

  end

  # response classes
  # ----------------
  class Row < OpenStruct; end
  class Facet < OpenStruct; end
end
