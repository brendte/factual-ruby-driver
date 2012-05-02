require 'spec_helper'

describe Factual::Write::Submit do
  include TestHelpers

  before(:each) do
    @token = get_token
    @api = get_api(@token)
    @basic_params = {
      :table => "global",
      :user => "user123",
      :values => { :name => "McDonalds" } }
    @klass = Factual::Write::Submit
    @submit = @klass.new(@api, @basic_params)
  end

  it "should be able to write a basic submit input" do
    @submit.write
    @token.last_url.should == "http://api.v3.factual.com/t/global/submit"
    @token.last_body.should == "user=user123&values=%7B%22name%22%3A%22McDonalds%22%7D"
  end

  it "should be able to set a table" do
    @submit.table("places").write
    @token.last_url.should == "http://api.v3.factual.com/t/places/submit"
    @token.last_body.should == "user=user123&values=%7B%22name%22%3A%22McDonalds%22%7D"
  end

  it "should be able to set a user" do
    @submit.user("user456").write
    @token.last_url.should == "http://api.v3.factual.com/t/global/submit"
    @token.last_body.should == "user=user456&values=%7B%22name%22%3A%22McDonalds%22%7D"
  end

  it "should be able to set a factual_id" do
    @submit.factual_id("1234567890").write
    @token.last_url.should == "http://api.v3.factual.com/t/global/1234567890/submit"
    @token.last_body.should == "user=user123&values=%7B%22name%22%3A%22McDonalds%22%7D"
  end

  it "should be able to set values" do
    @submit.values({ :new_key => :new_value }).write
    @token.last_url.should == "http://api.v3.factual.com/t/global/submit"
    @token.last_body.should == "user=user123&values=%7B%22new_key%22%3A%22new_value%22%7D"
  end

  it "should be able to set comment and reference" do
    @submit.table("places").comment('foobar').reference('yahoo.com/d/').write
    @token.last_url.should == "http://api.v3.factual.com/t/places/submit"
    @token.last_body.should == "user=user123&values=%7B%22name%22%3A%22McDonalds%22%7D&comment=foobar&reference=yahoo.com%2Fd%2F"
  end

  it "should not allow an invalid param" do
    raised = false
    begin
      bad_submit = @klass.new(@api, :foo => "bar")
    rescue
      raised = true
    end
    raised.should == true
  end

  it "should be able to return a valid path if no factual_id is set" do
    @submit.path.should == "/t/global/submit"
  end

  it "should be able to return a valid path if a factual_id is set" do
    @submit.factual_id("foo").path.should == "/t/global/foo/submit"
  end

  it "should be able to return a body" do
    @submit.body.should == "user=user123&values=%7B%22name%22%3A%22McDonalds%22%7D"
  end
end
