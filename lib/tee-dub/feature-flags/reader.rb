require 'forwardable'

module TeeDub module FeatureFlags

  BaseFlag = Struct.new(:name,:description,:default)

  FullFlag = Struct.new(:base_flag, :override) do
    extend Forwardable

    def_delegators :base_flag, :name, :description, :default
  end

  class Reader
    def self.blank_reader
      new( [], {} )
    end

    def initialize( base_flags, overrides )
      @base_flags = load_base_flags( base_flags )
      @overrides = overrides
    end

    def base_flags
      @base_flags.values.inject({}) { |h,flag| h[flag.name] = flag.default; h }
    end

    def full_flags
      @base_flags.values.map do |base_flag|
        FullFlag.new(base_flag, @overrides[base_flag.name.to_sym])
      end
    end

    def on?(flag_name)
      flag_name = flag_name.to_sym

      return false unless base_flag_exists?( flag_name )

      @overrides.fetch(flag_name) do
        # fall back to defaults
        fetch_base_flag(flag_name).default
      end
    end

    private

    def load_base_flags( flags )
      Hash[ *flags.map{ |f| [f.name.to_sym, f] }.flatten ]
    end

    def base_flag_exists?( flag_name )
      @base_flags.has_key?( flag_name )
    end

    def fetch_base_flag( flag_name )
      @base_flags.fetch( flag_name ) do
        BaseFlag.new( nil, nil, false ) # if we couldn't find a flag return a Null flag
      end
    end
  end

end end

