require 'oauth'
require 'json'
require 'uri'
require 'ostruct'

module Factual
  class Api
    API_V3_HOST        = "http://api.v3.factual.com"
    DRIVER_VERSION_TAG = "factual-ruby-driver-1.0"
    PARAM_ALIASES      = { :search => :q }

    # initializer
    def initialize(key, secret)
      @access_token = OAuth::AccessToken.new(OAuth::Consumer.new(key, secret))
    end

    # actions
    def crosswalk(factual_id)
      Query.new(
          :api    => self,
          :action => :crosswalk,
          :path   => "places/crosswalk",
          :params => { :factual_id => factual_id })
    end

    def resolve(values)
      Query.new(
          :api    => self,
          :action => :resolve,
          :path   => "places/resolve",
          :params => { :values => values })
    end

    def table(table_id_or_alias)
      Query.new(
          :api    => self,
          :action => :read,
          :path   => "t/#{table_id_or_alias}",
          :params => Hash.new)
    end

    # requesting
    def request(path, params)
      url     = "#{API_V3_HOST}/#{path}?#{query_string(params)}"
      headers = {"X-Factual-Lib" => DRIVER_VERSION_TAG}

      @access_token.get(url, headers)
    end

    private

    def query_string(params)
      arr = []
      params.each do |param, v|
        param_alias = PARAM_ALIASES[param.to_sym] || param.to_sym

        v = v.to_json if v.class == Hash
        arr << "#{param_alias}=#{URI.escape(v.to_s)}"
      end

      arr.join("&")
    end

  end

  class Query

    # helper functions
    DEFAULT_LIMIT = 20

    VALID_PARAMS = {
      :read      => [ :filters, :search, :geo, :sort, :select, :limit, :offset ],
      :resolve   => [ :values ],
      :crosswalk => [ :factual_id ],
      :schema    => [ ],
      :any       => [ :include_count ]
    }

    # initializer
    def initialize(options)
      @api    = options[:api]
      @action = options[:action]
      @path   = options[:path]
      @params = options[:params]
    end

    def get_options
      {
        :api    => @api,
        :action => @action,
        :path   => @path,
        :params => @params.clone
      }
    end

    # helper functions
    # attributes, after 'get'
    def first
      read_response["data"].first
    end

    def rows
      read_response["data"]
    end

    def total_count
      read_response["total_row_count"]
    end


    def schema
      unless @schema_response
        @path  += "/schema"
        @schema_response = response(:schema)
      end

      @schema_response["view"]
    end

    # query builder, returns immutable ojbects
    VALID_PARAMS.values.flatten.uniq.each do |param|
      define_method(param) do |*args|
        val = (args.length == 1) ? args.first : args.join(',')

        options = self.get_options
        options[:params][param] = val
        Query.new(options)
      end
    end

    # sugar
    def sort_desc(*args)
      columns = args.collect{ |col|"#{col}:desc" }

      options = self.get_options
      options[:params][:sort] = columns.join(',')
      Query.new(options)
    end

    def page(page_num, paging_opts = {})
      limit = (paging_opts[:per] || paging_opts["per"]).to_i
      limit = DEFAULT_LIMIT if limit < 1

      page_num = page_num.to_i
      page_num = 1 if page_num < 1
      offset   = (page_num - 1) * limit

      options = self.get_options
      options[:params][:limit]  = limit
      options[:params][:offset] = offset
      Query.new(options)
    end

    # requesting
    private

    def read_response
      unless @read_response
        # always include count for reads
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
