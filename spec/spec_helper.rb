require 'bundler/setup'
require 'rspec'
require 'rack/test'
require 'webmock/rspec'
require 'rakwik'

if RUBY_VERSION.match /^1\.8/
  require 'spec/lib/compat'
end

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
