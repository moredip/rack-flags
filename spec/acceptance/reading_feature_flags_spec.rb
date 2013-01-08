require_relative '../spec_helper'

require 'sinatra'
require 'rack/test'

class ReaderApp < Sinatra::Base
  enable :raise_errors
  disable :show_exceptions 

  get "/" do
    flags = TeeDub::FeatureFlags.for_env(env)

    output = []
    if flags.on?( :foo )
      output << "foo is on"
    else
      output << "foo is off"
    end

    if flags.on?( :bar )
      output << "bar is on"
    else
      output << "bar is off"
    end

    output.join("; ")
  end
end


describe 'reading feature flags in an app' do
  include Rack::Test::Methods

  let( :config_file ) { Tempfile.new('tee-dub-feature-flags acceptance test example config file') }
  let( :config_contents ){ "" }
  let( :feature_flag_cookie ){ "" }

  before :each do
    config_file.write( config_contents )
    config_file.flush

    set_cookie("#{TeeDub::FeatureFlags::CookieCodec::COOKIE_KEY}=#{feature_flag_cookie}")
  end

  after :each do
    config_file.unlink
  end

  let( :app ) do
    yaml_path = config_file.path
    Rack::Builder.new do
      use TeeDub::FeatureFlags::RackMiddleware, yaml_path: yaml_path
      run ReaderApp
    end
  end

  context 'no base flags, no overrides' do
    it 'should interpret both foo and bar as off by default' do
      get '/'
      last_response.body.should == 'foo is off; bar is off'
    end
  end

  context 'foo defined as a base flag, defaulted to true' do
    let( :config_contents ) do
      <<-EOS
      foo: 
        default: true
      EOS
    end

    it 'should interpret foo as on and bar as off' do
      get '/'
      last_response.body.should == 'foo is on; bar is off'
    end
  end

  context 'foo defaults to false, bar defaults to true' do
    let( :config_contents ) do
      <<-EOS
      foo: 
        default: false
      bar: 
        default: true
      EOS
    end

    it 'should interpret foo as off and bar as on' do
      get '/'
      last_response.body.should == 'foo is off; bar is on'
    end
  end

  context 'foo and bar both default to true, bar is overridden to false' do
    let( :config_contents ) do
      <<-EOS
      foo: 
        default: true
      bar: 
        default: true
      EOS
    end

    let( :feature_flag_cookie){ "!bar" }

    it 'should interpret foo as on and bar as off' do
      get '/'
      last_response.body.should == 'foo is on; bar is off'
    end
  end

end
