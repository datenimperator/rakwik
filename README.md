# Rakwik

Server-side integration of web tracking methods does not require Javascript snippets
or tracking images to be includd in the actual frontend. Rakwik implements asynchronous
tracking, so it tries to keep the time low, needed to count a particular request.

Unlike client-side tracking, server-side tracking can be used independently of frontend
encryption. Your application requires SSL encryption, but your installation of Piwik
does not support it? That's what Rakwik ist built for: It can track a request using http
while the original request came in over https, without the browser having to warn about
mixed content.

## Installation

Add this line to your application's Gemfile:

    gem 'rakwik'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rakwik

## Usage

Rakwik comes as a Rack-compatible middleware which needs to be added to your application's
middleware stack on startup.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
