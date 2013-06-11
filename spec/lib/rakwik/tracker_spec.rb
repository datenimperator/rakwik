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
      expect(WebMock).to have_requested(:post, tracker_data[:piwik_url]).with{|req|
        posted_data = URI::decode_www_form(req.body).
          inject(Hash.new){ |h, raw| h[raw[0]] = raw[1]; h }
      }
      expect(posted_data).to include(
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
      expect(posted_data["rand"]).not_to be_nil
      expect(posted_data["gt_ms"]).not_to be_nil
    end

    it "accepts requests without user agent" do
        # Trigger a request to our inner app that should be tracked
        get '/'

        # wait a little while to let EventMachine send the request
        sleep 0.1

        # What now?
        headers = nil
        expect(WebMock).to have_requested(:post, tracker_data[:piwik_url]).with{|req|
          headers = req.headers
        }

        expect(headers).to include(
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
      sleep 0.1

      # What now?
      posted_data = nil
      expect(WebMock).to have_requested(:post, tracker_data[:piwik_url]).with{|req|
        posted_data = URI::decode_www_form(req.body).
          inject(Hash.new){ |h, raw| h[raw[0]] = raw[1]; h }
      }

      expect(posted_data["_id"]).not_to be_nil
      expect(posted_data["_id"]).to match(/[0-9a-f]{16}/)
    end
  end

  context 'with path option' do
    let(:app) {
      Rakwik::Tracker.new(
        lambda { |env| [200, {"Content-Type"=>"text/plain"}, ["Hello."]] },
        tracker_data
      )
    }

    let(:tracker_data) {
      {
        :piwik_url => 'http://example.com/piwik.php',
        :site_id => 1,
        :token_auth => 'foobar',
        :path => path
      }
    }

    context 'as regexp' do
      let(:path) { /^\/foo.*$/ }

      it 'should track foo* pathes' do
        get '/foo'
        sleep 0.01

        get '/foo/bar'
        sleep 0.01

        get '/foobar'
        sleep 0.01

        expect(WebMock).to have_requested(:post, tracker_data[:piwik_url]).times(3)
      end

      it 'should not track other pathes' do
        get '/fo'
        sleep 0.01

        get '/index'
        sleep 0.01

        get '/bar/foo'
        sleep 0.01

        expect(WebMock).to have_requested(:post, tracker_data[:piwik_url]).times(0)
      end
    end

    context 'as proc' do
      let(:path) { Proc.new { |path| path.length == 5 }}

      it 'should track pathes of length 5' do
        get '/foos'
        sleep 0.01

        get '/a/bc'
        sleep 0.01

        expect(WebMock).to have_requested(:post, tracker_data[:piwik_url]).times(2)
      end

      it 'should not track other pathes' do
        get '/fo'
        sleep 0.01

        get '/index'
        sleep 0.01

        get '/bar/foo'
        sleep 0.01

        expect(WebMock).to have_requested(:post, tracker_data[:piwik_url]).times(0)
      end
    end

    context 'as string' do
      let(:path) { "/api" }

      it 'should track pathes that start with given string' do
        get '/api/v2/users'
        sleep 0.01

        get '/api'
        sleep 0.01

        get '/api/v2/users.json'
        sleep 0.01

        expect(WebMock).to have_requested(:post, tracker_data[:piwik_url]).times(3)
      end

      it 'should not track other pathes' do
        get '/'
        sleep 0.01

        get '/users.html'
        sleep 0.01

        get '/downloads/session.json'
        sleep 0.01

        expect(WebMock).to have_requested(:post, tracker_data[:piwik_url]).times(0)
      end
    end
  end
end
