require 'spec_helper'

describe Factual::Query::Resolve do
  include TestHelpers

  before(:each) do
    @token = get_token
    @api = get_api(@token)
    @resolve = Factual::Query::Resolve.new(@api)
    @base = "http://api.v3.factual.com/places/resolve?"
  end

  it "should be able to set values" do
    @resolve.values({:name => "McDonalds"}).rows
    expected_url = @base + "values={\"name\":\"McDonalds\"}"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to include a count" do
    @resolve.include_count(true).rows
    expected_url = @base + "include_count=true"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to get the total count" do
    @resolve.total_count
    expected_url = @base + "include_count=true&limit=1"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to get the schema" do
    @resolve.schema
    expected_url = "http://api.v3.factual.com/places/resolve/schema?"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to fetch the action" do
    @resolve.action.should == :resolve
  end

  it "should be able to fetch the path" do
    @resolve.path.should == "places/resolve"
  end

  it "should be able to fetch the params" do
    expected_params = { :include_count => true }
    @resolve.include_count(true).params.should == expected_params
  end

  it "should be able to fetch the rows" do
    @resolve.rows.map { |r| r["key"] }.should == ["value1", "value2", "value3"]
  end

  it "should be able to get the first row" do
    @resolve.first["key"].should == "value1"
  end

  it "should be able to get the last row" do
    @resolve.last["key"].should == "value3"
  end

  it "should be able to get a value at a specific index" do
    @resolve[1]["key"].should == "value2"
  end
end
