$LOAD_PATH << File.expand_path('../../lib', __FILE__)

require 'sinatra/base'
require 'tee-dub-feature-flags'

require 'pry'

class App < Sinatra::Base  

  get(/.+/) do
    #flags = TeeDubFeatureFlags::FlagOverrides.from_env(env)
    flags = TeeDub::FeatureFlags.for_env(env)
    "hello, world. Cookie Flags:<br/>#{flags.base_flags.inspect}"
  end
end

TeeDubFeatureFlags::Defaults.load_from( File.expand_path('../flags.yaml',__FILE__) )

app = Rack::Builder.new do
  use TeeDubFeatureFlags::RackMiddleware
  use TeeDub::FeatureFlags::RackMiddleware, yaml_path: File.expand_path('../flags.yaml',__FILE__)

  map '/feature_flags' do
    run TeeDubFeatureFlags::AdminApp.new
  end

  map '/' do 
    run App
  end

end

run app
