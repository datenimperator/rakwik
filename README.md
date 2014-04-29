# Rakwik

[![Build Status](https://travis-ci.org/datenimperator/rakwik.png)](https://travis-ci.org/datenimperator/rakwik)

*Server-side* integration of web tracking methods does not require Javascript snippets
or tracking images to be includd in the actual frontend. Rakwik implements asynchronous
tracking, so it tries to keep the time low that is needed to count a particular request.

![Server-side tracking](https://github.com/datenimperator/rakwik/wiki/server-side_tracking.png)

Unlike client-side tracking, server-side tracking can be used independently of frontend
encryption. Your application requires SSL encryption, but your installation of Piwik
does not support it? That's what Rakwik ist built for: It can track a request using http
while the original request came in over https, without the browser having to warn the
user about mixed content.

## Pros and cons

Using server-side tracking, you can track all kinds of information that are visible to
your server. Most certainly the URL, IP address and referrer are used, also session
information to identify subsequent requests from the same client.

However, it's hard to track client-specific information like screen resolution and plugin
support since the server has no way to detect details like such.

## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'rakwik'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rakwik

## Usage

Rakwik comes as a Rack-compatible middleware which needs to be added to your application's
middleware stack on startup.

``` ruby
config.middleware.use Rakwik::Tracker,
    :piwik_url  => 'http://your.piwik.host/piwik.php',
    :site_id    => 'your_site_id', # eg. 1
    :token_auth => 'yoursecrettoken'
```

The `:token_auth` is needed since Rakwik will tell Piwik to record hits from another IP
than its own. The token_auth must be either the Super User token_auth, or a user with
"admin" permission for this website ID.

### Action names

Piwik allows to set a custom action name which will be used in reports instead of the original
URL. To use it from your Rails application, include it into your controller like such:

``` ruby
require 'rakwik/helpers'

class ApplicationController < ActionController::Base
  # ...
  include Rakwik::Helpers
end
```

In the particular controller activate it by using the `action_name` class method:

``` ruby
class BooksController < ApplicationController
  action_name :page_title
  
  # GET /books
  # GET /books.xml
  def index
    @books = Book.all
    @page_title = "Books"

    respond_with @books
  end
end
```

Currently, `action_name` points to a instance variable.

## Warden integration

Since version 0.4.0 Rakwik detects [Warden](/hassox/warden) based credentials, eg. from [Devise](/plataformatec/devise). It'll create a MD5 hash of the current user instance to reliably identify subsequent requests of the same user.

## TODO

*  ~~Handle tracking cookies~~ no way to do this asynchronously
*  Implement a helper to set the action title ~~from the controller~~ or view
*  Implement a way to provide custom variables from the controller or view
*  Implement a way to detect client capabilities without a separate request
*  ~~Detect [Warden](/hassox/warden) based credentials, eg. from [Devise](/plataformatec/devise)~~
*  ~~Track 404 responses~~
*  ~~Implement meaningful specs~~

## Reference

*  http://piwik.org/docs/tracking-api/reference/

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
