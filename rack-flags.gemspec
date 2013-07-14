# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rack-flags/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Pete Hodgson", "Ryan Oglesby"]
  gem.email         = ["git@thepete.net"]
  gem.description   = 'Simple cookie-based feature flags using Rack'
  gem.summary       = 'Simple cookie-based feature flags using Rack'
  gem.homepage      = ""

  all_files = `git ls-files`.split($\)

  gem.files         = all_files.grep(%r{^(lib|resources)/})
  gem.executables   = all_files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = all_files.grep(%r{^(test|spec|features)/})
  gem.name          = "rack-flags"
  gem.require_paths = ["lib"]
  gem.version       = RackFlags::VERSION

  gem.add_dependency( "rake" )
  gem.add_dependency( "rack", ["~>1.4"] )
  gem.add_dependency( "sinatra", ["~>1.3"] )

  gem.add_development_dependency( "pry-debugger" )

  gem.add_development_dependency( "rspec-core" )
  gem.add_development_dependency( "rspec-expectations" )
  gem.add_development_dependency( "rr" )
  gem.add_development_dependency( "capybara" )
end
