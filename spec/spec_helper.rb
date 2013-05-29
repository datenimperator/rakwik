require 'bundler/setup'
require 'rspec'
require 'rack/test'
#require 'rack'
require 'rakwik'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
