require 'spec_helper'

describe Factual::Query::Table do
  include TestHelpers

  before(:each) do
    @token = get_token
    @api = get_api(@token)
    @table_name = "places"
    @table = Factual::Query::Table.new(@api, "t/#{@table_name}")
    @base = "http://api.v3.factual.com/t/places?"
  end

  it "should be able to do a compound query" do
    @table.filters("category" => "Food & Beverage > Restaurants").search("sushi", "sashimi")
      .geo("$circle" => {"$center" => [34.06021, -118.41828], "$meters" => 5000})
      .sort("name").page(2, :per => 10).rows
    expected_url = @base + "filters={\"category\":\"Food & Beverage > Restaurants\"}" + 
      "&q=sushi,sashimi&geo={\"$circle\":{\"$center\":[34.06021,-118.41828],\"$meters\":5000}}" + 
      "&sort=name&limit=10&offset=10"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to use filters" do
    @table.filters("country" => "US").rows
    expected_url = @base + "filters={\"country\":\"US\"}"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to search" do
    @table.search("suchi", "sashimi").rows
    expected_url = @base + "q=suchi,sashimi"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to use a geo parameter" do
    @table.geo("$circle" => {"$center" => [34.06021, -118.41828],
               "$meters" => 5000}).rows
    expected_url = @base + "geo={\"$circle\":{\"$center\":[34.06021,-118.41828],\"$meters\":5000}}"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to sort in ascending order" do
    @table.sort("name").rows
    expected_url = @base + "sort=name"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to sort in descending order" do
    @table.sort_desc("name").rows
    expected_url = @base + "sort=name:desc"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to select specific columns" do
    @table.select(:name, :website).rows
    expected_url = @base + "select=name,website"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to limit the number of returned rows" do
    @table.limit(5).rows
    expected_url = @base + "limit=5"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to set an offset for a query" do
    @table.offset(5).rows
    expected_url = @base + "offset=5"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to set whether the count is included" do
    @table.include_count(true).rows
    expected_url = @base + "include_count=true"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to set the page" do
    @table.page(5).rows
    expected_url = @base + "limit=20&offset=80"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to get the total count" do
    @table.total_count
    expected_url = @base + "include_count=true&limit=1"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to get the schema" do
    @table.schema
    expected_url = "http://api.v3.factual.com/t/places/schema?"
    CGI::unescape(@token.last_url).should == expected_url
  end

  it "should be able to fetch the action" do
    @table.action.should == :read
  end

  it "should be able to fetch the path" do
    @table.path.should == "t/places"
  end

  it "should be able to fetch the params" do
    expected_params = {:filters => {"country"=>"US"}}
    @table.filters("country" => "US").params.should == expected_params
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
