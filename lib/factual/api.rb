require 'json'
require 'uri'

class Factual
  class API
    API_V3_HOST        = "http://api.v3.factual.com"
    DRIVER_VERSION_TAG = "factual-ruby-driver-1.0"
    PARAM_ALIASES      = { :search => :q }

    def initialize(access_token)
      @access_token = access_token
    end

    def execute(query)
      params_with_count = query.params.merge(:include_count => true)
      handle_request(query.action || :read, query.path, params_with_count)
    end

    def schema(query)
      handle_request(:schema, query.path + "/schema", query.params)["view"]
    end

    private

    def handle_request(action, path, params)
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
end
