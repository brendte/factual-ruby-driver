require 'spec_helper'

describe Factual::Flag do
  include TestHelpers

  before(:each) do
    @token = get_token
    @api = get_api(@token)
    @flag = Factual::Flag.new(@api, {})
  end

  it "should be able to use the minimal params (table, factual_id, problem, user)"

  it "should not allow an invalid problem"

  it "should not allow an invalid param"

  it "should be able to set a comment"

  it "should be able to set the debug flag"

  it "should be able to set a reference"

  it "should be able to return a path"

  it "should be able to return a body"

  it "should be able to write the flag"
end
