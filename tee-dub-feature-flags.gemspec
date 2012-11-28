# -*- encoding: utf-8 -*-
require File.expand_path('../lib/tee-dub-feature-flags/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Pete Hodgson"]
  gem.email         = ["git@thepete.net"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "tee-dub-feature-flags"
  gem.require_paths = ["lib"]
  gem.version       = TeeDubFeatureFlags::VERSION

  gem.add_dependency( "rack", ["~>1.4"] )

  gem.add_development_dependency( "sinatra" ) # for example app
  gem.add_development_dependency( "pry" )
  gem.add_development_dependency( "pry-debugger" )
end
