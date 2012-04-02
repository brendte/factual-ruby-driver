require 'spec_helper'

describe Factual::Query::Crosswalk do
  include TestHelpers

  before(:each) do
    @token = get_token
    @api = get_api(@token)
    @table = Factual::Query::Crosswalk.new(@api)
    @base = "http://api.v3.factual.com/places/crosswalk?"
  end

  it "should be able to set the factual_id" do
    @table.factual_id("abcde").rows
    expected_url = @base + "factual_id=abcde"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to set an 'only' value" do
    @table.only("yelp").rows
    expected_url = @base + "only=yelp"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to set a limit" do
    @table.limit(5).rows
    expected_url = @base + "limit=5"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to include the count" do
    @table.include_count(true).rows
    expected_url = @base + "include_count=true"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to get the total count" do
    @table.total_count
    expected_url = @base + "include_count=true&limit=1"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to get the schema" do
    @table.schema
    expected_url = "http://api.v3.factual.com/places/crosswalk/schema?"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to fetch the action" do
    @table.action.should == :crosswalk
  end

  it "should be able to fetch the path" do
    @table.path.should == "places/crosswalk"
  end

  it "should be able to fetch the params" do
    expected_params = { :include_count => true }
    @table.include_count(true).params.should == expected_params
  end

  it "should be able to fetch the rows" do
    @table.rows.map { |r| r["key"] }.should == ["value1", "value2", "value3"]
  end

  it "should be able to get the first row" do
    @table.first["key"].should == "value1"
  end

  it "should be able to get the last row" do
    @table.last["key"].should == "value3"
  end

  it "should be able to get a value at a specific index" do
    @table[1]["key"].should == "value2"
  end
end
