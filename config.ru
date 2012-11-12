$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'sinatra/base'
require 'tee-dub-feature-flags/rack_middleware'
require 'tee-dub-feature-flags/flags'

class App < Sinatra::Base  

  get(/.+/) do
    flags = TeeDubFeatureFlags::Flags.from_env(env)

    flags.set('foo')
    flags.unset('bar')

    "hello, world. Cookie Flags:<br/>#{flags.all_flags.inspect}"
  end
end

use TeeDubFeatureFlags::RackMiddleware
run App
