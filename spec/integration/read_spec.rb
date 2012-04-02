require 'spec_helper'
require 'yaml'

CREDENTIALS_FILE = File.expand_path('./key_secret.yaml', File.dirname(__FILE__))

describe "Read APIs" do
  before(:all) do
    credentials = YAML.load(File.read(CREDENTIALS_FILE))
    key = credentials["key"]
    secret = credentials["secret"]
    @factual = Factual.new(key, secret)
  end

  it "should be able to do a table query" do
    rows = @factual.table("places").search("sushi", "sashimi")
      .filters("category" => "Food & Beverage > Restaurants")
      .geo("$circle" => {"$center" => [34.06021, -118.41828], "$meters" => 5000})
      .sort("name").page(2, :per => 10).rows
    rows.class.should == Array
    rows.each do |row|
      row.class.should == Hash
      row.keys.should_not be_empty
    end
  end

  it "should be able to do a resolve query" do
    rows = @factual.resolve("name" => "McDonalds",
                            "address" => "10451 Santa Monica Blvd",
                            "region" => "CA",
                            "postcode" => "90025").rows
    rows.class.should == Array
    rows.each do |row|
      row.class.should == Hash
      row.keys.should_not be_empty
    end
  end

  it "should be able to do a crosswalk query" do
    rows = @factual.crosswalk("110ace9f-80a7-47d3-9170-e9317624ebd9").rows
    rows.class.should == Array
    rows.each do |row|
      row.class.should == Hash
      row.keys.should_not be_empty
    end
  end
end
