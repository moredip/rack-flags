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
    Capybara.app = app
  end

  let( :app ) do
    yaml_path = ff_config_file_path
    Rack::Builder.new do
      use RackFlags::RackMiddleware, yaml_path: yaml_path
      run RackFlags::AdminApp.new
    end
  end

  let(:on_flag_section){ page.find('section[data-flag-name="on_by_default"]') }
  let(:off_flag_section){ page.find('section[data-flag-name="off_by_default"]') }
  let(:update_button){ page.find('input[type="submit"]') }

  it 'successfully GETs the admin page' do
    visit '/'
    status_code.should == 200
  end

  it 'renders the feature flag name, default and description' do
    visit '/'

    on_flag_section.should_not be_nil
    on_flag_section.find('h3').text.should == 'on_by_default'
    on_flag_section.find('p').text.should == 'this flag on by default'
    on_flag_section.find('label.default').text.should include('Default (On)')

    off_flag_section.should_not be_nil
    off_flag_section.find('h3').text.should == 'off_by_default'
    off_flag_section.find('p').text.should == 'this flag off by default'
    off_flag_section.find('label.default').text.should include('Default (Off)')
  end

  it 'selects the default option if there are no cookies present' do
    visit '/'

    verify_flag_section( on_flag_section, :default )
    verify_flag_section( off_flag_section, :default )
  end

  it 'allows switching off a flag defaulted to on' do
    visit '/'
    
    on_flag_section.choose( 'Off' )
    update_button.click

    verify_flag_section( on_flag_section, :off )
    verify_flag_section( off_flag_section, :default )
  end

  def verify_flag_section( section, expected_state )
    case expected_state.to_sym
    when :default
      section.find('label.default input').should be_checked

      section.find('label.on input').should_not be_checked
      section.find('label.off input').should_not be_checked
    when :on
      section.find('label.on input').should be_checked

      section.find('label.default input').should_not be_checked
      section.find('label.off input').should_not be_checked
    when :off
      section.find('label.off input').should be_checked

      section.find('label.default input').should_not be_checked
      section.find('label.on input').should_not be_checked
    else 
      raise "unrecognized state '#{expected_state}'"
    end
  end
end
