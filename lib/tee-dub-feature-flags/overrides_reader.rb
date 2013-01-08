module TeeDub module FeatureFlags
  class OverridesReader
    def self.for_env(env)
      new(env)
    end

    def initialize(env)
      @env = env
    end
  end

end end
