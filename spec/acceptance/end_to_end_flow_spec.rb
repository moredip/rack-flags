require_relative 'spec_helper'
require_relative 'support/page_objects/admin_page'
require_relative 'support/page_objects/reader_page'

describe 'end-to-end flow of setting a feature flag in the admin app and seeing its effect' do

  let( :app ) do
    yaml_path = ff_config_file_path
    Rack::Builder.new do
      use RackFlags::RackMiddleware, yaml_path: yaml_path
      map('/reader'){ run ReaderApp }
      map('/feature_flags'){ run RackFlags::AdminApp.new }
    end
  end

  let( :feature_flag_config ) do
    {
      foo: { default: true },
      bar: { default: false }
    }
  end

  before :each do
    ff_config_file_contains( feature_flag_config )
    Capybara.app = app
  end

  it 'overriding an off flag to on' do
    ReaderPage.visiting('/reader') do |page|
      page.verify_flag_is_on('foo')
      page.verify_flag_is_off('bar')
    end

    AdminPage.visiting('/feature_flags') do |page|
      page.turn_on_flag_name('bar')
    end

    ReaderPage.visiting('/reader') do |page|
      page.verify_flag_is_on('foo')
      page.verify_flag_is_on('bar')
    end
  end

end
