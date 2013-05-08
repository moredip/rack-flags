module TeeDub module FeatureFlags

  class CookieCodec
    COOKIE_KEY='tee-dub-feature-flags'

    class Parser
      attr_reader :overrides

      def self.parse(cookie_value)
        parser = new 
        parser.parse(cookie_value)
        parser.overrides
      end

      def initialize()
        @overrides = {}
      end

      def parse(raw_overrides)
        return if raw_overrides.nil?

        raw_overrides.split(' ').each do |override|
          parse_override(override)
        end
      end

      private

      BANG_DETECTOR = Regexp.compile(/^!(.+)/)

      def parse_override(override)
        if override_without_bang = override[BANG_DETECTOR,1]
          add_override(override_without_bang,false)
        else
          add_override(override,true)
        end
      end

      def add_override( name, value )
        @overrides[name.to_sym] = value
      end
    end

    def overrides_from_env(env)
      req = Rack::Request.new(env)
      raw_overrides = req.cookies[COOKIE_KEY]
      Parser.parse( raw_overrides )
    end
  end

end end
