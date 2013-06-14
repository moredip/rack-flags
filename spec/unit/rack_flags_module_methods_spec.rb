require_relative 'spec_helper'

module RackFlags
  describe '.for_env' do
    it 'should return the flags which the middleware stuffed in the env' do
      fake_env = {RackMiddleware::ENV_KEY => 'fake flags from env'}
      RackFlags.for_env(fake_env).should == 'fake flags from env'
    end

    it 'returns a generic empty reader if none is in the env' do
      fake_env = {}
      reader = RackFlags.for_env(fake_env)
      reader.should_not be_nil
      reader.should respond_to(:on?)
    end
  end
end

