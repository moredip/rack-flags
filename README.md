# rack-flags

Simple cookie-based [feature flags](http://martinfowler.com/bliki/FeatureToggle.html) using Rack. 

[![ZOMG SNAP Build Status](https://snap-ci.com/o7uuLFuvOgdCkggpKyYlVDO088LLbnjCnzqT--ViVqI/build_image)](https://snap-ci.com/projects/moredip/rack-flags/build_history)

[![Build Status](https://travis-ci.org/moredip/rack-flags.png?branch=master)](https://travis-ci.org/moredip/rack-flags)
[![Code Climate](https://codeclimate.com/github/moredip/rack-flags.png)](https://codeclimate.com/github/moredip/rack-flags)

rack-flags ships in two parts:
- a simple rack middleware which detects the feature flag set for a specific web request
- a simple rack app for administering which feature flags are set for your browser

## Getting Started

### 1. Add rack-flags to your Gemfile

### 2. Write a yaml file describing your features

Something like:

```yaml 
foo: 
  description: This is my first feature flag
  default: true
show_new_ui: 
  description: render our experimental new UI to the user
  default: false
```

### 3. Add the RackFlags middleware and admin app to your rack stack

In a Rails application, first add the middleware in `application.rb`

```ruby
config.middleware.use RackFlags::RackMiddleware, yaml_path: File.expand_path('../feature_flags.yaml',__FILE__), disable_config_caching: Rails.env.development?
```

Then, mount the AdminApp to some route in `routes.rb`

```ruby
mount RackFlags::AdminApp, at: 'some_route'
```

Or, using a `config.ru` something along the lines of:

```ruby
require 'rack-flags'

app = Rack::Builder.new do
  use RackFlags::RackMiddleware, yaml_path: File.expand_path('../feature_flags.yaml',__FILE__)

  map '/feature_flags' do
    run RackFlags::AdminApp.new
  end

  map '/' do 
    run MyApp
  end
end

run app
```

### 4. Check the state of a feature flags when handling a request

For example, if you're using Rails you could do:

```ruby

  class SomeController < ApplicationController
    def some_action
      features = RackFlags.for_env(request.env)
      @show_whizzy_bits = features.on?(:show_new_ui)
    end
  end
```

Or if you're using Sinatra maybe you'd do:

```ruby

  get("/some/page") do
    features = RackFlags.for_env(env)

    if features.on?(:show_new_ui)
      render_new_whizzy_ui
    else
      render_boring_safe_ui
    end
  end
```

### 5. Override your feature flags in the admin page 

Assuming you have a `config.ru` similar to the example above you can visit /feature_flags in a browser to see the set of feature flags defined for your app. 
From that page you can also override the state of whichever flags you want, just for *your* browser.
Subsequently when your browser makes requests to your web app it will see the overridden feature flag set.

This is a simple lightweight way to expose work-in-progress functionality to developers, testers or other internal users.

## So wait, what is this doing?

The approach is described in [this blog post](http://blog.thepete.net/blog/2012/11/06/cookie-based-feature-flag-overrides/). 

Your app defines a set of known feature flags which are either off or on by default, using a simple YAML file. Users can override the default state of these feature flags just for their specific browser by visiting a special admin page. That admin page sets a special cookie which is interpreted by the rack-flags middleware. Your application asks rack-flags which feature flags are on or off for the current request. If there is an override cookie the rack-flags middleware includes that when reporting the feature flags states to the user.

