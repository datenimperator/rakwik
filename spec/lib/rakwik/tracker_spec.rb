require 'spec_helper'

describe Rakwik::Tracker do
  extend Rack::Test::Methods

  let(:tracker_data) {
    {
      :piwik_url => 'http://example.com/piwik.php',
      :site_id => 1,
      :token_auth => 'foobar'
    }
  }

  def app
    Rakwik::Tracker.new(
      lambda { |env| [200, {"Content-Type"=>"text/plain"}, ["Hello. The time is #{Time.now}"]] },
      tracker_data
    )
  end

  before(:each) do
    stub_request(:post, tracker_data[:piwik_url]).to_return(:status => 200, :body => lambda{|req| req.body})
  end

  it "tracks requests asynchronously" do
    # Trigger a request to our inner app that should be tracked
    get '/'

    # wait a little while to let EventMachine send the request
    sleep 0.01

    # What now?
    WebMock.should have_requested(:post, tracker_data[:piwik_url]).with{|req|
      posted_data = URI::decode_www_form(req.body).inject(Hash.new){|h, raw| h[raw[0]] = raw[1]; h}
      posted_data.should include("token_auth"=>"foobar", "idsite"=>"1", "rec"=>"1", "url" => "http://example.org/", "apiv"=>"1")
      true
    }
  end
end
