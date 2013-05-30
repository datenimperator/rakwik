require 'bundler/setup'
require 'rspec'
require 'rack/test'
require 'webmock/rspec'
require 'rakwik'

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
