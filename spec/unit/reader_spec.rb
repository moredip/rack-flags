require_relative 'spec_helper'

module TeeDub module FeatureFlags

  describe Reader do
    let( :base_flags ) do
      [
        BaseFlag.new( :usually_on, 'a flag', true ),
        BaseFlag.new( :usually_off, 'another flag', false )
      ]
    end
    subject( :reader ){ Reader.new( base_flags, overrides ) }

    context 'no overrides' do
      let( :overrides ){ {} }

      specify 'on? is true for a flag which is on by default' do
        subject.on?( :usually_on ).should be_true
      end

      specify 'on? is false for a flag which is off by default' do
        subject.on?( :usually_off ).should be_false
      end

      specify 'on? is false for unknown flags' do
        subject.on?( :unknown_flag ).should be_false
      end
    end

    context 'overridden to false' do
      let( :overrides ){ {usually_on: false} }

      specify 'on? is false' do
        subject.on?( :usually_on ).should be_false
      end
    end

    context 'overridding a flag which has no base' do
      let( :overrides ){ {no_base: true} }
      specify 'on? is false' do
        subject.on?( :no_base ).should be_false
      end
    end
  end

end end
