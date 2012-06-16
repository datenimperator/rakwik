require 'em-http'
require 'pp'

module Rakwik
  class Tracker
    DEFAULT = {}

  	def initialize(app, options = {})
      @app, @options = app, DEFAULT.merge(options)
      missing = [:piwik_url, :site_id].detect{ |e| @options[e].nil? }
      raise "Missing config value: :#{missing}" if missing
  	end

    def call(env)
      request = Rack::Request.new(env)
      status, headers, response = @app.call(env)
      track(request)
      [status, headers, response]
    end

    private

    def piwik_url
      @options[:piwik_url]
    end

    def piwik_id
      @options[:site_id]
    end

    def track(request)
      header = {
        'User-Agent' => request.user_agent,
        'Accept-Encoding' => request.env['HTTP_ACCEPT_ENCODING']
      }
      data = {
        'idsite' => piwik_id,
        'rec' => 1,
        'url' => request.url,
        'apiv' => 1
      }
      data['urlref'] = request.referer unless request.referer.nil?
      EM.schedule do
        http = connection(piwik_url).get :head => header, :query => data
      end
    end

    def connection(url)
      EventMachine::HttpRequest.new(url)
    end

  end
end