require_relative 'spec_helper'

describe 'displaying flags in admin app' do
  include Rack::Test::Methods

  let( :feature_flag_config ) do
    {
      on_by_default: {
        'default' => true,
        'description' => 'this flag on by default'
      },
      off_by_default: {
        'default' => false,
        'description' => 'this flag off by default'
      }
    }
  end

  before :each do
    ff_config_file_contains feature_flag_config
    TeeDubFeatureFlags::Defaults.load_from ff_config_file_path
  end

  let( :app ) do
    yaml_path = ff_config_file_path
    Rack::Builder.new do
      use TeeDubFeatureFlags::RackMiddleware
      use TeeDub::FeatureFlags::RackMiddleware, yaml_path: yaml_path
      run TeeDubFeatureFlags::AdminApp.new
    end
  end

  it 'should GET the admin page' do
    get '/'
    last_response.status.should == 200
  end

  it 'should render the feature flag name, default and description' do
    get '/'
    last_response.body.should include('<h3>on_by_default</h3>')
    last_response.body.should include('<p>this flag on by default</p>')
    #last_response.body.should include('<label>Default (On)')

    last_response.body.should include('<h3>off_by_default</h3>')
    last_response.body.should include('<p>this flag off by default</p>')
    #last_response.body.should include('<label>Default (Off)')
  end
end
