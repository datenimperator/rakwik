require 'em-http'

module Rakwik
  class Tracker
  
    include Rack::Response::Helpers
    
    DEFAULT = {
      :track_404 => true
    }

    def initialize(app, options = {})
      @app, @options = app, DEFAULT.merge(options)
      missing = [:piwik_url, :site_id, :token_auth].detect{ |e| @options[e].nil? }
      raise "Missing config value: :#{missing}" if missing
    end

    def call(env)
      @status, @headers, @body = @app.call(env)
      track Rack::Request.new(env) if track?
      [@status, @headers, @body]
    end

    private
    
    def track?
      ok? || (not_found? && @options[:track_404] === true)
    end

    def piwik_url
      @options[:piwik_url]
    end

    def piwik_id
      @options[:site_id]
    end

    def token_auth
      @options[:token_auth]
    end
    
    def extract(request)
      header = {
        'User-Agent' => request.user_agent
      }
      header['Accept-Language'] = request.env['HTTP_ACCEPT_LANGUAGE'] unless request.env['HTTP_ACCEPT_LANGUAGE'].nil?
      header['DNT'] = request.env['HTTP_DNT'] unless request.env['HTTP_DNT'].nil?

      if c=request.cookies
        # we'll forward piwik cookies only
        c.delete_if{ |name, value| !(name =~ /^_pk_id\.|^_pk_ses\./) }
        unless c.empty?
          header['Cookie'] = c.map{|k,v| "#{k}=#{v}"}.join(';')
        end
      end

      data = {
        'idsite'     => piwik_id,
        'token_auth' => token_auth,
        'rec'        => 1,
        'url'        => request.url,
        'cip'        => request.ip,
        'rand'       => rand(1000000),
        'apiv'       => 1
      }
      data['action_name'] = request.env['rakwik.action_name'] unless request.env['rakwik.action_name'].nil?
      data['urlref'] = request.referer unless request.referer.nil?
      
      if not_found? && @options[:track_404] === true
        data['action_name'] = "404/URL = #{data['url'].gsub(/\//, '%2f')}/From = #{data['urlref'].gsub(/\//, '%2f')}"
      end
      
      [header, data]
    end

    def track(request)
      h, d = extract(request)
      EventMachine.schedule do
        http = connection(piwik_url).get :head => h, :query => d
        http.errback {
          time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
          request.env['rack.errors'].puts "[#{time}] ERROR Rakwik::Tracker: #{http.error}"
        }
      end
    end

    def connection(url)
      EventMachine::HttpRequest.new(url)
    end

  end
end
