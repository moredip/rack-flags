require_relative 'spec_helper'

module TeeDub module FeatureFlags

  class DerivedFlags
    def initialize( base_flags )
    end
  end

  #class OverridesReader
    #def initialize
      #raise NotImplementedError
    #end
  #end

  describe RackMiddleware do

    def mock_out_config_loading
      stub(Config).load(anything){ OpenStruct.new( flags: 'fake flags from config' ) }
    end

    it 'raise an exception if no yaml path is provided' do
      lambda{
        RackMiddleware.new( :fake_app, {} )
      }.should raise_error( ArgumentError, 'yaml_path must be provided' )
    end

    it 'loads the config from the specified yaml file' do
      mock(Config).load('some/config/path')
      RackMiddleware.new( :fake_app, yaml_path: 'some/config/path' )
    end

    describe '#call' do

      it 'creates DerivedFlags using the config when called' do
        stub(Config).load(anything){ OpenStruct.new( flags: 'fake flags from config' ) }
        mock(DerivedFlags).new( 'fake flags from config' )

        middleware = RackMiddleware.new( :fake_app, yaml_path: 'blah' )
        middleware.call( {} )
      end

      xit 'creates an overrides reader' do
        mock_out_config_loading

        fake_env = :fake_env
        mock(OverridesReader).for_env( fake_env )

        middleware = RackMiddleware.new( :fake_app, yaml_path: 'blah' )
        middleware.call( fake_env )
      end

      it 'passes through to downstream app'
    end
  end

end end
