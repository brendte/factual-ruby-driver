require 'oauth'
require 'json'
require 'uri'

# Represents access to Factual data and features, via the public API.
class Factual
  HOME = "http://api.v3.factual.com"
  DRIVER_VERSION_TAG = "factual-ruby-driver-1.0"

  # Initializes authentication to the Factual API.
  # Must specify a valid developer key and secret.
  def initialize(key, secret)
    @access_token = OAuth::AccessToken.new(OAuth::Consumer.new(key, secret))
  end

  # Executes a read request against Factual, including all supported
  # query parameters such as limit, offset, full text search, and row filters.
  def find(table, query)
    get("t/#{table}", query)
  end

  # Executes a Crosswalk request against Factual.
  def crosswalk(table, query)
    get("#{table}/crosswalk", query)
  end

  # Executes a Resolve request against Factual.
  def resolve(table, values)
    get("#{table}/resolve", {:values => values})
  end

  # Executes a Crossref request against Factual.
  def crossref(table, query)
    get("#{table}/crossref", query)
  end

  private

  def query_string(query)
    arr = []
    query.each do |k,v|
      v = v.to_json if v.class == Hash
      arr << "#{k}=#{URI.escape(v)}"
    end
    return arr.join("&")
  end

  def get(path, query)
    @access_token.get(
    "#{HOME}/#{path}?#{query_string(query)}",
    {"X-Factual-Lib" => DRIVER_VERSION_TAG})
  end
end
