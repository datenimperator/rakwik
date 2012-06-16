# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rakwik/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Christian Aust"]
  gem.email         = ["github@kontakt.software-consultant.net"]
  gem.description   = %q{Rakwik is a server-side tracker integration for the Piwik opensource
web statistics software. It's easy to integrate into rack-based applications and does not require
frontend Javascript inclusion.}
  gem.summary       = %q{Rack-based server-side asynchronous Piwik tracker integration.}
  gem.homepage      = "https://github.com/datenimperator/rakwik"

  gem.add_dependency "rack"
  gem.add_dependency "em-http-request"

  gem.add_development_dependency "rspec"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rakwik"
  gem.require_paths = ["lib"]
  gem.version       = Rakwik::VERSION
  gem.platform      = Gem::Platform::RUBY
end
