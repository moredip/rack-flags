require_relative 'spec_helper'

describe 'displaying flags in admin app' do
  include Capybara::DSL

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
    Capybara.app = app
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
    visit '/'
    status_code.should == 200
  end

  it 'should render the feature flag name, default and description' do
    visit '/'

    on_flag_section = page.find('section[data-flag-name="on_by_default"]')
    on_flag_section.should_not be_nil
    on_flag_section.find('h3').text.should == 'on_by_default'
    on_flag_section.find('p').text.should == 'this flag on by default'
    on_flag_section.find('label.default').text.should include('Default (On)')

    off_flag_section = page.find('section[data-flag-name="off_by_default"]')
    off_flag_section.should_not be_nil
    off_flag_section.find('h3').text.should == 'off_by_default'
    off_flag_section.find('p').text.should == 'this flag off by default'
    off_flag_section.find('label.default').text.should include('Default (Off)')
  end
end
