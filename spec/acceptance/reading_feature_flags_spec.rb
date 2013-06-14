require_relative 'spec_helper'
require_relative 'support/reader_app'

describe 'reading feature flags in an app' do
  include Rack::Test::Methods

  let( :feature_flag_config ){ {} }
  let( :feature_flag_cookie ){ "" }

  before :each do
    ff_config_file_contains feature_flag_config
    set_feature_flags_cookie feature_flag_cookie
  end

  let( :app ) do
    yaml_path = ff_config_file_path
    Rack::Builder.new do
      use RackFlags::RackMiddleware, yaml_path: yaml_path
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
    let( :feature_flag_config ) do
      {
        foo: { default: true }
      }
    end

    it 'should interpret foo as on and bar as off' do
      get '/'
      last_response.body.should == 'foo is on; bar is off'
    end
  end

  context 'foo defaults to false, bar defaults to true' do
    let( :feature_flag_config ) do
      {
        foo: { default: false },
        bar: { default: true }
      }
    end

    it 'should interpret foo as off and bar as on' do
      get '/'
      last_response.body.should == 'foo is off; bar is on'
    end
  end

  context 'foo and bar both default to true, bar is overridden to false' do
    let( :feature_flag_config ) do
      {
        foo: { default: true },
        bar:  { default: true }
      }
    end

    let( :feature_flag_cookie){ "!bar" }

    it 'should interpret foo as on and bar as off' do
      get '/'
      last_response.body.should == 'foo is on; bar is off'
    end
  end

end
