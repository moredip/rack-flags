require_relative 'spec_helper'

module RackFlags
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