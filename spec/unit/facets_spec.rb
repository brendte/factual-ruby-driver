require 'spec_helper'

describe Factual::Query::Facets do
  include TestHelpers

  before(:each) do
    @token = get_token
    @api = get_api(@token)
    @table_name = "places"
    @cols = ["category", "locality"]
    @facets = Factual::Query::Facets.new(@api, "t/#{@table_name}").select(@cols)
    @base = "http://api.v3.factual.com/t/places/facets?"
  end

  it "should be able to do a compound query" do
  end

  it "should be abled to get facets by column" do
  puts @facets.columns.inspect
    category_facets = @facets.columns["category"]
    category_facets.class.should == Hash
    category_facets.each do |cat, num|
      num.is_a?(Integer).should_be true
    end
  end
end
