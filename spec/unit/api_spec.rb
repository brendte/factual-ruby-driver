require 'spec_helper'

describe Factual::API do
  include TestHelpers

  before(:each) do
    @token = get_token
    @api = get_api(@token)
  end

  it "should be able to get a query" do
    table = Factual::Query::Table.new(@api, "t/places")
    query = table.search("foo")
    @api.get(query)
    @token.last_url.should == "http://api.v3.factual.com/t/places?q=foo"
  end

  it "should be able to post a query" do
    flag_params = {
      :table => "global",
      :factual_id => "id123",
      :problem => :duplicate,
      :user => "user123" }
    flag = Factual::Flag.new(@api, flag_params)
    @api.post(flag)
    @token.last_url.should == "http://api.v3.factual.com/t/global/id123/flag"
    @token.last_body.should == "problem=duplicate&user=user123"
  end

  it "should be able to get a query with additional params" do
    table = Factual::Query::Table.new(@api, "t/places")
    query = table.search("foo")
    @api.get(query, "bar" => "baz")
    @token.last_url.should == "http://api.v3.factual.com/t/places?q=foo&bar=baz"
  end

  it "should be able to get the schema for a table" do
    table = Factual::Query::Table.new(@api, "t/places")
    @api.schema(table)
    @token.last_url.should == "http://api.v3.factual.com/t/places/schema?"
  end

  it "should be able to do a raw read" do
    @api.raw_read("/t/foo?bar=baz")
    @token.last_url.should == "http://api.v3.factual.com/t/foo?bar=baz"
  end
end
