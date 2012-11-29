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

  def app
    Rack::Builder.new do
      use TeeDubFeatureFlags::RackMiddleware
      run ReaderApp
    end
  end

  it 'should interpret both foo and bar as off by default' do
    get '/'
    last_response.body.should == 'foo is off; bar is off'
  end

end
