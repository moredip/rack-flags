module TeeDubFeatureFlags
  class Flag
    attr_reader :name, :description, :default

    def initialize(args)
      @name, @description, @default = args.values_at(:name,:description,:default)
    end
  end
end
