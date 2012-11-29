module TeeDub module FeatureFlags

  class Config
    def self.load( yaml )
      raise NotImplementedError
    end
  end

end end
