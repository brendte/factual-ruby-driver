# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
Gem::Specification.new do |s|
  s.name        = "factual-api"
  s.version     =  "0.2"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Forrest Cao", "Aaron Crow"]
  s.email       = ["aaron@factual.com"]
  s.homepage    = "http://github.com/Factual/factual-ruby-driver"
  s.summary     = "Ruby driver for Factual"
  s.description = "Factual's official Ruby driver for the Factual public API."
  s.required_rubygems_version = ">= 1.3.6"
  s.add_development_dependency "rspec"
  s.files        = Dir.glob("{lib}/factual_api.rb") + %w(README.md CHANGELOG.md)
  s.executables  = []
  s.require_path = 'lib'
end
