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

  it "should be able to use the minimal params (table, factual_id, problem, user)" do
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

  it "should be able to set the debug flag"

  it "should be able to set a reference"

  it "should be able to return a path"

  it "should be able to return a body"

  it "should be able to write the flag"
end
