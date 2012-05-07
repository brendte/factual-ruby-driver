$LOAD_PATH << File.expand_path('../lib', File.dirname(__FILE__))

require 'rspec'
require 'factual'

RSpec.configure do |c|
    c.mock_with :rspec
end

class MockAccessToken
  class Response
    def initialize(type, action = :read)
      @type   = type
      @action = action
    end

    def body
      { "status" => "ok", "response" => response }.to_json
    end

    def response
      if @type == :get
        if @action == :read
          {
            "data" => [
              { :key => "value1" },
              { :key => "value2" },
              { :key => "value3" }
            ]
          }
        elsif @action == :facets
          {
            "data" => {
              'category' => {
                "legal & financial" => 123456,
                "shopping"          => 23456,
                "education"         => 3456
              },
              'locality' => {
                "los angeles" => 123456,
                "new york"    => 23456,
                "houston"     => 3456
              }
            }
          }
        end
      elsif @type == :post
        "OK"
      end
    end
  end

  attr_reader :last_url, :last_body

  def initialize(action)
    @action    = action
    @last_url  = nil
    @last_body = nil
  end

  def get(url, headers)
    @last_url = url
    Response.new(:get, @action)
  end

  def post(url, body, headers)
    @last_url = url
    @last_body = body
    Response.new(:post)
  end
end

module TestHelpers
  def get_token(action=:read)
    MockAccessToken.new(action)
  end

  def get_api(token)
    Factual::API.new(token)
  end
end
