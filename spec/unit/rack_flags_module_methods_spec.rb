require_relative 'spec_helper'

module RackFlags
  describe '.for_env' do
    it 'should return the flags which the middleware stuffed in the env' do
      fake_env = {RackMiddleware::ENV_KEY => 'fake flags from env'}
      expect(RackFlags.for_env(fake_env)).to eq 'fake flags from env'
    end

    it 'returns a generic empty reader if none is in the env' do
      fake_env = {}
      reader = RackFlags.for_env(fake_env)
      expect(reader).to_not be_nil
      expect(reader).to respond_to(:on?)
    end
  end
end

