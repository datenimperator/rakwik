require 'em-http'
require 'pp'

module Rakwik
  class Tracker
    DEFAULT = {}

  	def initialize(app, options = {})
      @app, @options = app, DEFAULT.merge(options)
      missing = [:piwik_url, :site_id, :token_auth].detect{ |e| @options[e].nil? }
      raise "Missing config value: :#{missing}" if missing
  	end

    def call(env)
      status, headers, response = @app.call(env)
      track Rack::Request.new(env)
      [status, headers, response]
    end

    private

    def piwik_url
      @options[:piwik_url]
    end

    def piwik_id
      @options[:site_id]
    end

    def token_auth
      @options[:token_auth]
    end

    def track(request)
      header = {
        'User-Agent' => request.user_agent,
        'Accept-Language' => request.env["HTTP_ACCEPT_LANGUAGE"]
      }
      data = {
        'idsite'     => piwik_id,
        'token_auth' => token_auth,
        'rec'        => 1,
        'url'        => request.url,
        'cip'        => request.ip,
        'apiv'       => 1
      }
      data['urlref'] = request.referer unless request.referer.nil?
      EventMachine.schedule do
        http = connection(piwik_url).get :head => header, :query => data
      end
    end

    def connection(url)
      EventMachine::HttpRequest.new(url)
    end

  end
end