require 'spec_helper'
require 'lib/rakwik/test/application'

describe Rakwik::Tracker do
  extend Rack::Test::Methods

  def app
    Rakwik::Tracker.new(Rakwik::Test::Application.new, :piwik_url => 'http://example.com/piwik.php', :site_id => 1, :token_auth => 'foobar' )
  end

  it "says hello" do
    get '/'
    last_response.should.be.ok
    last_response.body.should.equal 'Hello World'
  end
end
