require 'spec_helper'

describe Factual::Contribute do
  include TestHelpers

  before(:each) do
    @token = get_token
    @api = get_api(@token)
    @basic_params = {
      :table => "global",
      :user => "user123",
      :values => { :name => "McDonalds" } }
    @klass = Factual::Contribute
    @contribute = @klass.new(@api, @basic_params)
  end

  it "should be able to write a basic contribute input" do
    @contribute.write
    @token.last_url.should == "http://api.v3.factual.com/t/global/contribute"
    @token.last_body.should == "user=user123&values=%7B%22name%22%3A%22McDonalds%22%7D"
  end

  it "should be able to set a table" do
    @contribute.table("places").write
    @token.last_url.should == "http://api.v3.factual.com/t/places/contribute"
    @token.last_body.should == "user=user123&values=%7B%22name%22%3A%22McDonalds%22%7D"
  end

  it "should be able to set a user" do
    @contribute.user("user456").write
    @token.last_url.should == "http://api.v3.factual.com/t/global/contribute"
    @token.last_body.should == "user=user456&values=%7B%22name%22%3A%22McDonalds%22%7D"
  end

  it "should be able to set a factual_id" do
    @contribute.factual_id("1234567890").write
    @token.last_url.should == "http://api.v3.factual.com/t/global/1234567890/contribute"
    @token.last_body.should == "user=user123&values=%7B%22name%22%3A%22McDonalds%22%7D"
  end

  it "should be able to set values" do
    @contribute.values({ :new_key => :new_value }).write
    @token.last_url.should == "http://api.v3.factual.com/t/global/contribute"
    @token.last_body.should == "user=user123&values=%7B%22new_key%22%3A%22new_value%22%7D"
  end

  it "should not allow an invalid param" do
    raised = false
    begin
      bad_contribute = @klass.new(@api, :foo => "bar")
    rescue
      raised = true
    end
    raised.should == true
  end

  it "should be able to return a valid path if no factual_id is set" do
    @contribute.path.should == "/t/global/contribute"
  end

  it "should be able to return a valid path if a factual_id is set" do
    @contribute.factual_id("foo").path.should == "/t/global/foo/contribute"
  end

  it "should be able to return a body" do
    @contribute.body.should == "user=user123&values=%7B%22name%22%3A%22McDonalds%22%7D"
  end
end
