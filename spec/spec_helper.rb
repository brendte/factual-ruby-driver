$LOAD_PATH << File.expand_path('../lib', File.dirname(__FILE__))

require 'rspec'
require 'factual'

RSpec.configure do |c|
    c.mock_with :rspec
end

class MockAccessToken
  class Response
    def body
      { "status" => "ok", "response" => response }.to_json
    end

    def response
      {
        "data" => [
          { :key => "value1" },
          { :key => "value2" },
          { :key => "value3" }
        ]
      }
    end
  end

  attr_reader :last_url

  def initialize
    @last_url = nil
  end

  def get(url, headers)
    @last_url = url
    Response.new
  end
end

module TestHelpers
  def get_token
    MockAccessToken.new
  end

  def get_api(token)
    Factual::API.new(token)
  end
end
