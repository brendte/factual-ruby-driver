require 'spec_helper'

describe Factual::Flag do
  include TestHelpers

  before(:each) do
    @token = get_token
    @api = get_api(@token)
    @basic_params = {
      :table => "global",
      :factual_id => "id123",
      :problem => :duplicate,
      :user => "user123" }
    @flag = Factual::Flag.new(@api, @basic_params)
  end

  it "should be able to write a basic flag" do
    @flag.write
    @token.last_url.should == "http://api.v3.factual.com/t/global/id123/flag"
    @token.last_body.should == "problem=duplicate&user=user123"
  end

  it "should not allow an invalid problem" do
    bad_params = @basic_params.merge!(:problem => :foo)
    raised = false
    begin
      bad_flag = Factual::Flag.new(@api, bad_params)
    rescue
      raised = true
    end
    raised.should == true
  end

  it "should not allow an invalid param" do
    bad_params = @basic_params.merge!(:foo => :bar)
    raised = false
    begin
      bad_flag = Factual::Flag.new(@api, bad_params)
    rescue
      raised = true
    end
    raised.should == true
  end

  it "should be able to set a comment" do
    @flag.comment("This is my comment").write
    @token.last_url.should == "http://api.v3.factual.com/t/global/id123/flag"
    @token.last_body.should == "problem=duplicate&user=user123&comment=This+is+my+comment"
  end

  it "should be able to set the debug flag" do
    @flag.debug(true).write
    @token.last_url.should == "http://api.v3.factual.com/t/global/id123/flag"
    @token.last_body.should == "problem=duplicate&user=user123&debug=true"
  end

  it "should be able to set a reference" do
    @flag.reference("http://www.google.com").write
    @token.last_url.should == "http://api.v3.factual.com/t/global/id123/flag"
    @token.last_body.should == "problem=duplicate&user=user123&reference=http%3A%2F%2Fwww.google.com"
  end

  it "should be able to return a path" do
    @flag.path.should == "/t/global/id123/flag"
  end

  it "should be able to return a body" do
    @flag.body.should == "problem=duplicate&user=user123"
  end
end
