require_relative 'spec_helper'

module TeeDub module FeatureFlags
  describe '.for_env' do
    it 'should return the flags which the middleware stuffed in the env' do
      fake_env = {RackMiddleware::ENV_KEY => 'fake flags from env'}
      TeeDub::FeatureFlags.for_env(fake_env).should == 'fake flags from env'
    end

    it 'returns a generic empty reader if none is in the env'
  end
end end

