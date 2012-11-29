require_relative 'spec_helper'

module TeeDub module FeatureFlags
 
  describe Config do
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

    it 'loads yaml from the specified path' do
      Tempfile.open('tee-dub-feature-flag-config-unit-test') do |f|
        f.write( yaml )
        f.flush

        config = Config.load( f.path )

        config.should have(2).flags
      end

    end
  end

end end
