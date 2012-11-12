require 'yaml'
require 'tee-dub-feature-flags/flag'

module TeeDubFeatureFlags
  class Defaults

    class << self
      def load_from(path)
        @path = path
      end

      def load
        raw_config = File.open( @path, 'r' ){ |f| YAML::load(f) }
        new( raw_config )
      end
    end

    def initialize( raw_config )
      @raw_config = raw_config
    end

    def flags
      flags = {}
      @raw_config.each do |flag_name,flag_config|
        flags[flag_name] = Flag.new(
          name: flag_name, 
          description: flag_config['description'],
          default: flag_config['default']
        )
      end
      flags
    end

  end
end
