$LOAD_PATH << File.expand_path('../../lib', __FILE__)

require 'sinatra/base'
require 'tee-dub-feature-flags'

require 'pry'

class App < Sinatra::Base  

  get(/.+/) do
    reader = TeeDub::FeatureFlags.for_env(env)
    final_values = reader.base_flags.keys.inject({}) do |final_values, flag_name|
      final_values[flag_name.to_sym] = reader.on?(flag_name)
      final_values
    end

    <<-EOS
      Default Flags:<br/>#{reader.base_flags.inspect}
      <br/>
      With Local Overrides:<br/>#{final_values.inspect}
      <br/>
      <br/>
      <a href="feature_flags">Admin Page</a>
    EOS
  end
end

app = Rack::Builder.new do
  use TeeDub::FeatureFlags::RackMiddleware, yaml_path: File.expand_path('../flags.yaml',__FILE__)

  map '/feature_flags' do
    run TeeDub::FeatureFlags::AdminApp.new
  end

  map '/' do 
    run App
  end

end

run app
