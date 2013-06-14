require_relative 'spec_helper'

module RackFlags

  describe AdminApp do
    describe '#call' do
      let(:fake_env) { {} }
      let(:admin_app) { AdminApp.new }

      context 'when the request is a get' do
        let(:fake_env) { {'REQUEST_METHOD' => 'GET'} }

        it 'returns a successful HTML response' do
          status, headers, body = admin_app.call(fake_env)

          expect(status).to eq(200)
          expect(headers).to include({'Content-Type' => 'text/html'})
          expect(body).to_not be_empty
        end

      end

      context 'when the request is a post' do
        let(:fake_env) { {'REQUEST_METHOD' => 'POST', 'SCRIPT_NAME' => 'admin-app' } }

        before do
          any_instance_of(Rack::Request) do |rack_request|
            stub(rack_request).POST { {} }
          end
        end

        it 'returns a 303 redirect response' do
          status, headers , body = admin_app.call(fake_env)

          expect(status).to eq(303)
          expect(headers).to include({'Location' => 'admin-app'})
          expect(body).to be_empty
        end

        it 'sets the cookie using the post params' do
          any_instance_of(Rack::Request) do |rack_request|
            stub(rack_request).POST { {flag_1: 'on', flag_2: 'off', flag_3: 'default'} }
          end

          stub.proxy(CookieCodec).new do |cookie_codec|
            mock(cookie_codec).generate_cookie_from({flag_1: true, flag_2: false, flag_3: nil}) { 'flag_1 !flag2' }
          end

          any_instance_of(Rack::Response) do |rack_response|
            mock(rack_response).set_cookie(CookieCodec::COOKIE_KEY, 'flag_1 !flag2')
          end

          admin_app.call(fake_env)
        end

        it 'returns the finished response' do
          stub.proxy(Rack::Response).new do |rack_response|
            mock(rack_response).finish { 'finished rack response' }
          end

          response = admin_app.call(fake_env)

          expect(response).to eq('finished rack response')
        end

      end

      context 'when the request is something else' do
        let(:fake_env) { {'REQUEST_METHOD' => 'OTHER'} }

        it 'returns a 405 method not allowed response' do
          status, headers , body = admin_app.call(fake_env)

          expect(status).to eq(405)
          expect(headers).to be_empty
          expect(body).to eq('405 - METHOD NOT ALLOWED')
        end
      end

    end

  end

  describe FullFlagPresenter do
    describe '#default' do
      let(:full_flag) { FullFlag.new(base_flag, nil) }

      subject(:full_flag_presenter) { FullFlagPresenter.new(full_flag) }

      context 'when the default is true' do
        let(:base_flag) { BaseFlag.new('name', 'description', true) }

        its(:default) { should == 'On' }
      end

      context 'when the default is false' do
        let(:base_flag) { BaseFlag.new('name', 'description', false) }

        its(:default) { should == 'Off' }
      end
    end

    describe '#checked_attributes_for' do
      let(:full_flag) { FullFlag.new(mock(BaseFlag), override) }

      subject(:full_flag_presenter) { FullFlagPresenter.new(full_flag) }

      context 'when the default value is not overridden' do
        let(:final_value) { nil }
        let(:override) { nil }

        specify 'only its default checked state is "checked"' do
          expect(subject.checked_attribute_for(:default)).to eq('checked')
          expect(subject.checked_attribute_for(:on)).to eq('')
          expect(subject.checked_attribute_for(:off)).to eq('')
        end
      end

      context 'when the default value is overridden to true' do
        let(:final_value) { nil }
        let(:override) { true }

        specify 'only its on checked state is "checked"' do
          expect(subject.checked_attribute_for(:default)).to eq('')
          expect(subject.checked_attribute_for(:on)).to eq('checked')
          expect(subject.checked_attribute_for(:off)).to eq('')
        end
      end

      context 'when the default value is overridden to false' do
        let(:final_value) { nil }
        let(:override) { false }

        specify 'only its off checked state is "checked"' do
          expect(subject.checked_attribute_for(:default)).to eq('')
          expect(subject.checked_attribute_for(:on)).to eq('')
          expect(subject.checked_attribute_for(:off)).to eq('checked')
        end
      end
    end
  end

end