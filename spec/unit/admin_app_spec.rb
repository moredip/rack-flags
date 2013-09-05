require_relative 'spec_helper'

module RackFlags
  describe AdminApp do
    include Rack::Test::Methods

    let(:app) { RackFlags::AdminApp }

    describe 'GET' do
      it 'is a success' do
        get '/'

        expect(last_response).to be_ok
        expect(last_response.body).to_not be_empty
      end
    end

    describe 'POST' do
      it 'is a redirect to GET' do
        post '/'

        expect(last_response.status).to eq(303)
        expect(last_response.location).to eq('http://example.org/') # Root path - Rack::Test::DEFAULT_HOST is example.org
        expect(last_response.body).to be_empty
      end

      it 'sets the cookie based on the posted params' do
        stub.proxy(CookieCodec).new do |cookie_codec|
          mock(cookie_codec).generate_cookie_from({flag_1: true, flag_2: false, flag_3: nil}) { 'flag_1 !flag_2' }
        end

        post '/', flag_1: 'on', flag_2: 'off', flag_3: 'default'

        expect(rack_mock_session.cookie_jar[CookieCodec::COOKIE_KEY]).to eq('flag_1 !flag_2')
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

    pending 'Changed this implementation' do
      describe '#checked_attributes_for' do
        let(:full_flag) { FullFlag.new(mock(BaseFlag), override) }

        subject(:full_flag_presenter) { FullFlagPresenter.new(full_flag) }

        context 'when the default value is not overridden' do
          let(:final_value) { nil }
          let(:override) { nil }

          specify 'only its default checked state is "checked"' do
            expect(subject.checked_attribute_for(:default)).to eq('checked')
            expect(subject.checked_attribute_for(:on)).to eq('')
            expect(subject.checked_attribute_for(:off)).to eq('checked')
          end
        end

        context 'when the default value is overridden to true' do
          let(:final_value) { nil }
          let(:override) { true }

          specify 'only its on checked state is "checked"' do
            #expect(subject.checked_attribute_for(:default)).to eq('')
            expect(subject.checked_attribute_for(:on)).to eq('checked')
            expect(subject.checked_attribute_for(:off)).to eq('')
          end
        end

        context 'when the default value is overridden to false' do
          let(:final_value) { nil }
          let(:override) { false }

          specify 'only its off checked state is "checked"' do
            #expect(subject.checked_attribute_for(:default)).to eq('')
            expect(subject.checked_attribute_for(:on)).to eq('')
            expect(subject.checked_attribute_for(:off)).to eq('checked')
          end
        end
      end
    end

  end

end