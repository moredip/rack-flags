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

    describe '#generate_cookie_from' do
      it 'returns a simple cookie' do
        admin_app_overrides = {flag_1: true}
        cookie = cookie_codec.generate_cookie_from(admin_app_overrides)

        expect(cookie).to eq('flag_1')
      end

      it 'returns a cookie with positive and negative values' do
        admin_app_overrides = {flag_1: true, flag_2: false}
        cookie = cookie_codec.generate_cookie_from(admin_app_overrides)

        expect(cookie).to eq('flag_1 !flag_2')
      end

      it 'returns a cookie with default values' do
        admin_app_overrides = {flag_1: true, flag_2: false, flag_3: nil}
        cookie = cookie_codec.generate_cookie_from(admin_app_overrides)

        expect(cookie).to eq('flag_1 !flag_2')
      end
    end

  end
end
