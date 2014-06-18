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

  before(:each) do
    stub_request(:post, tracker_data[:piwik_url]).
      to_return(:status => 200, :body => lambda{|req| req.body})
  end

  context "for anonymous requests" do
    let(:app) {
      Rakwik::Tracker.new(
        lambda { |env| [200, {"Content-Type"=>"text/plain"}, ["Hello."]] },
        tracker_data
      )
    }

    it "tracks requests asynchronously" do
      header "User-Agent", "SomeAgent"
      header "Referer", "http://example.org/referring_page"
      header "Accept-Language", "en"

      # Trigger a request to our inner app that should be tracked
      get '/'

      # wait a little while to let EventMachine send the request
      sleep 0.01

      # What now?
      posted_data = nil
      WebMock.should have_requested(:post, tracker_data[:piwik_url]).with{|req|
        posted_data = URI::decode_www_form(req.body).
          inject(Hash.new){ |h, raw| h[raw[0]] = raw[1]; h }
      }
      posted_data.should include(
        "token_auth"=>"foobar",
        "idsite"=>"1",
        "rec"=>"1",
        "url" => "http://example.org/",
        "cip" => "127.0.0.1",
        "apiv"=>"1",
        "ua"=>"SomeAgent",
        "lang"=>"en",
        "urlref"=>"http://example.org/referring_page"
      )
      posted_data["rand"].should_not be_nil
      posted_data["gt_ms"].should_not be_nil
    end

    it "accepts requests without user agent" do
        # Trigger a request to our inner app that should be tracked
        get '/'

        # wait a little while to let EventMachine send the request
        sleep 0.01

        # What now?
        headers = nil
        WebMock.should have_requested(:post, tracker_data[:piwik_url]).with{|req|
          headers = req.headers
        }

        headers.should include(
          "User-Agent"=>Rakwik::Tracker.user_agent
        )
    end

  end

  context "for Warden authenticated requests" do
    let(:app) {
      Warden::Manager.new Rakwik::Tracker.new(
          lambda { |env| [200, {"Content-Type"=>"text/plain"}, ["Hello."]] },
          tracker_data
        )
    }

    it "recognizes login data" do
      login_as 'test'
      get '/'

      # wait a little while to let EventMachine send the request
      sleep 0.01

      # What now?
      posted_data = nil
      WebMock.should have_requested(:post, tracker_data[:piwik_url]).with{|req|
        posted_data = URI::decode_www_form(req.body).
          inject(Hash.new){ |h, raw| h[raw[0]] = raw[1]; h }
      }

      posted_data["_id"].should_not be_nil
      posted_data["_id"].should match(/[0-9a-f]{16}/)
    end
  end

end
