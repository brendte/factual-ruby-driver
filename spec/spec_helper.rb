$LOAD_PATH << File.expand_path('../lib', File.dirname(__FILE__))

require 'rspec'
require 'factual'

RSpec.configure do |c|
    c.mock_with :rspec
end
