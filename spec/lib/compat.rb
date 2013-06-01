module URI
  def self.decode_www_form(raw)
  	raw.split('&').map{|s|s.split('=').map{|v| CGI::unescape(v)}}
  end
end
