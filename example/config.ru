$LOAD_PATH << File.expand_path('../../lib', __FILE__)

require 'sinatra/base'
require 'rack-flags'

require 'pry'

class App < Sinatra::Base  

  get(/.+/) do
    reader = RackFlags.for_env(env)
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
      <a href="admin/feature_flags">Admin Page</a>
    EOS
  end
end

app = Rack::Builder.new do
  use RackFlags::RackMiddleware, yaml_path: File.expand_path('../flags.yaml',__FILE__)

  map '/admin/feature_flags' do
    run RackFlags::AdminApp.new
  end

  map '/' do 
    run App
  end

end

run app
