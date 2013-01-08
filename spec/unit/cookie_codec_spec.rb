require_relative 'spec_helper'

module TeeDub::FeatureFlags
 
  describe CookieCodec do
    let(:cookie_codec){ CookieCodec.new }
    describe '#overrides_from_env' do
      subject(:overrides){ cookie_codec.overrides_from_env(env) }
      let(:env){ {'HTTP_COOKIE'=>cookie_header } }
      let(:cookie_header){ "#{CookieCodec::COOKIE_KEY}=#{Rack::Utils.escape(ff_cookie)};foo=bar" }

      context 'no cookie' do
        let(:env){ {} }
        it{ should == {} }
      end

      context 'empty cookie' do
        let(:ff_cookie){ '' }
        it{ should == {} }
      end

      context 'simple cookie' do
        let(:ff_cookie){ 'foo bar' }
        it{ should == {foo: true, bar: true} }
      end

      context 'cookie with positives and negatives' do
        let(:ff_cookie){ 'yes !no yes-sir !na-huh' }
        it{ should == {
          :yes => true, 
          :'yes-sir' => true,
          :no => false,
          :'na-huh' => false
        } }
      end
    end
  end
end
