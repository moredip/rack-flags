module TeeDubFeatureFlags
  class Flag
    attr_reader :name, :description, :default, :override

    def initialize(args)
      @name, @description, @default, @override = args.values_at(:name,:description,:default,:override)
    end

    def derived_state
      return false if default.nil?

      override.nil? ? default : override
    end

    def create_overridden_flag(override)
      self.class.new( 
        name: @name, 
        description: @description,
        default: @default,
        override: override
      )
    end
    
  end
end
