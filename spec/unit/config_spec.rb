require_relative 'spec_helper'

module RackFlags

  describe Config do
    let( :config_file ) { Tempfile.new('rack-flags-config-unit-test') }
    let( :yaml ) { raise NotImplementedError }


    before :each do
      config_file.write( yaml )
      config_file.flush
    end

    let(:config){ Config.load( config_file.path ) }

    after :each do
      config_file.unlink
    end

    context 'regular yaml' do
      let(:yaml) do
        <<-EOS
        foo:
          description: the description
          default: true
        bar:
          description: another description
          default: false
        EOS
      end

      it 'loads a set of BaseFlags' do
        expect(config).to have(2).flags
        expect(config.flags.map(&:name)).to include(:foo, :bar)
        expect(config.flags.map(&:description)).to include('the description', 'another description')
        expect(config.flags.map(&:default)).to include(true, false)
      end
    end

    context 'empty file' do
      let(:yaml){ "" }
      it 'loads as an empty config' do
        expect(config).to have(0).flags
      end
    end

    context 'symbolized yaml' do
      let :yaml do
        <<-EOS
          :foo:
            :default: true
            :description: a description
        EOS
      end

      subject(:flag){ config.flags.first }

      it { should_not be_nil }
      its(:default) { should be_truthy }
      its(:description) { should == "a description" }
    end
  end

end
