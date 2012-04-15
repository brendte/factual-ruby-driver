$LOAD_PATH << File.expand_path('../lib', File.dirname(__FILE__))

require 'rspec'
require 'factual'

RSpec.configure do |c|
    c.mock_with :rspec
end

class MockAccessToken
  class Response
    def initialize(type = :get)
      @type = type
    end

    def body
      { "status" => "ok", "response" => response }.to_json
    end

    def response
      if @type == :get
        {
          "data" => [
            { :key => "value1" },
            { :key => "value2" },
            { :key => "value3" }
          ]
        }
      elsif @type == :post
        "OK"
      end
    end
  end

  attr_reader :last_url, :last_body

  def initialize
    @last_url = nil
    @last_body = nil
  end

  def get(url, headers)
    @last_url = url
    Response.new
  end

  def post(url, body, headers)
    @last_url = url
    @last_body = body
    Response.new(:post)
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
