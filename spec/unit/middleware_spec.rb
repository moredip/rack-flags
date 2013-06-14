require_relative 'spec_helper'

module RackFlags

  describe RackMiddleware do

    def mock_out_config_loading
      stub(Config).load(anything){ OpenStruct.new( flags: {} ) }
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

      def create_middleware( fake_app = false)
        fake_app ||= Proc.new {}

        RackMiddleware.new( fake_app, yaml_path: 'blah' )
      end

      it 'creates a Reader using the config flags when called' do
        stub(Config).load(anything){ OpenStruct.new( flags: 'fake flags from config' ) }
        mock(Reader).new( 'fake flags from config', anything )

        middleware = create_middleware()
        middleware.call( {} )
      end

      it 'adds the reader to the env' do
        mock_out_config_loading

        mock(Reader).new(anything,anything){ 'fake derived flags' }

        middleware = create_middleware()
        fake_env = {}
        middleware.call( fake_env )
        fake_env[RackMiddleware::ENV_KEY].should == 'fake derived flags'
      end

      it 'reads overrides from cookies' do
        mock_out_config_loading

        fake_env = { fake: 'env' }


        fake_cookie_codec = mock( Object.new )
        mock(CookieCodec).new{ fake_cookie_codec }

        fake_cookie_codec.overrides_from_env( fake_env )

        create_middleware().call( fake_env )
      end

      it 'passes the overrides into the reader' do
        mock_out_config_loading

        mock(CookieCodec).new{ stub!.overrides_from_env{'fake overrides'} }
        mock(Reader).new( anything, 'fake overrides' )

        create_middleware().call( {} )
      end

      it 'passes through to downstream app' do
        mock_out_config_loading

        fake_app ||= Proc.new do
          "downstream app response"
        end

        middleware = create_middleware( fake_app )
        middleware_response = middleware.call( {} )

        middleware_response.should == "downstream app response"
      end
    end
  end

end
