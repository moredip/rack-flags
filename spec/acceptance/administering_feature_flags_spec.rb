require_relative 'spec_helper'
require_relative 'support/page_objects/admin_page'

describe 'displaying flags in admin app' do

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
    Capybara.app = app
  end

  let( :app ) do
    yaml_path = ff_config_file_path
    Rack::Builder.new do
      use RackFlags::RackMiddleware, yaml_path: yaml_path
      run RackFlags::AdminApp.new
    end
  end

  it 'successfully GETs the admin page' do
    AdminPage.visiting do |page|
      page.verify_status_code_is 200
    end
  end

  it 'renders the feature flag name, default and description' do
    AdminPage.visiting do |page|
      on_flag_section = page.section_for_flag_named('on_by_default')
      expect(on_flag_section).to_not be_nil
      expect(on_flag_section.find('h3').text).to eq 'on_by_default'
      expect(on_flag_section.find('p').text).to eq 'this flag on by default'
      expect(on_flag_section.find('label.default').text).to include('Default (On)')

      off_flag_section = page.section_for_flag_named('off_by_default')
      expect(off_flag_section).to_not be_nil
      expect(off_flag_section.find('h3').text).to eq 'off_by_default'
      expect(off_flag_section.find('p').text).to eq 'this flag off by default'
      expect(off_flag_section.find('label.default').text).to include('Default (Off)')
    end
  end

  it 'selects the default option if there are no cookies present' do
    AdminPage.visiting do |page|
      page.verify_flag_section( 'on_by_default', :default )
      page.verify_flag_section( 'off_by_default', :default )
    end
  end

  it 'allows switching off a flag defaulted to on' do
    AdminPage.visiting do |page|
      page.turn_off_flag_name('on_by_default')

      page.verify_flag_section( 'on_by_default', :off )
      page.verify_flag_section( 'off_by_default', :default )
    end
  end
end
