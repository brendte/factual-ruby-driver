require 'json'
require 'cgi'

class Factual
  class API
    API_V3_HOST        = "http://api.v3.factual.com"
    DRIVER_VERSION_TAG = "factual-ruby-driver-1.0"
    PARAM_ALIASES      = { :search => :q, :sort_asc => :sort }

    def initialize(access_token)
      @access_token = access_token
    end

    def execute(query, other_params={})
      merged_params = query.params.merge(other_params)
      handle_request(query.action || :read, query.path, merged_params)
    end

    def schema(query)
      handle_request(:schema, query.path + "/schema", query.params)["view"]
    end

    def raw_read(path)
      payload = JSON.parse(make_request("#{API_V3_HOST}#{path}").body)
      handle_payload(payload)
    end

    private

    def handle_request(action, path, params)
      url = "#{API_V3_HOST}/#{path}?#{query_string(params)}"
      payload = JSON.parse(make_request(url).body)
      handle_payload(payload)
    end

    def handle_payload(payload)
      raise StandardError.new(payload["message"]) unless payload["status"] == "ok"
      payload["response"]
    end

    def make_request(url)
      headers = { "X-Factual-Lib" => DRIVER_VERSION_TAG }
      @access_token.get(url, headers)
    end

    def query_string(params)
      query_array = params.keys.inject([]) do |array, key|
        param_alias = PARAM_ALIASES[key.to_sym] || key.to_sym
        value = params[key].class == Hash ? params[key].to_json : params[key].to_s
        array << "#{param_alias}=#{CGI.escape(value)}"
      end

      query_array.join("&")
    end
  end
end
