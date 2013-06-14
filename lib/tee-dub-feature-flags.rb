require 'tee-dub/feature-flags/reader'
require 'tee-dub/feature-flags/cookie_codec'
require 'tee-dub/feature-flags/config'
require 'tee-dub/feature-flags/rack_middleware'
require 'tee-dub/feature-flags/admin_app'

module TeeDub
  module FeatureFlags
    VERSION = "0.1.0"
    
    def self.for_env(env)
      env[RackMiddleware::ENV_KEY] || Reader.blank_reader
    end
  end
end
