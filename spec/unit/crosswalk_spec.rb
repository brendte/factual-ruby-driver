require 'spec_helper'

describe Factual::Query::Crosswalk do
  include TestHelpers

  before(:each) do
    @token = get_token
    @api = get_api(@token)
    @crosswalk = Factual::Query::Crosswalk.new(@api)
    @base = "http://api.v3.factual.com/places/crosswalk?"
  end

  it "should be able to set the factual_id" do
    @crosswalk.factual_id("abcde").rows
    expected_url = @base + "factual_id=abcde"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to set an 'only' value" do
    @crosswalk.only("yelp").rows
    expected_url = @base + "only=yelp"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to set a limit" do
    @crosswalk.limit(5).rows
    expected_url = @base + "limit=5"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to include the count" do
    @crosswalk.include_count(true).rows
    expected_url = @base + "include_count=true"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to get the total count" do
    @crosswalk.total_count
    expected_url = @base + "include_count=true&limit=1"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to get the schema" do
    @crosswalk.schema
    expected_url = "http://api.v3.factual.com/places/crosswalk/schema?"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to fetch the action" do
    @crosswalk.action.should == :crosswalk
  end

  it "should be able to fetch the path" do
    @crosswalk.path.should == "places/crosswalk"
  end

  it "should be able to fetch the params" do
    expected_params = { :include_count => true }
    @crosswalk.include_count(true).params.should == expected_params
  end

  it "should be able to fetch the rows" do
    @crosswalk.rows.map { |r| r["key"] }.should == ["value1", "value2", "value3"]
  end

  it "should be able to get the first row" do
    @crosswalk.first["key"].should == "value1"
  end

  it "should be able to get the last row" do
    @crosswalk.last["key"].should == "value3"
  end

  it "should be able to get a value at a specific index" do
    @crosswalk[1]["key"].should == "value2"
  end
end
