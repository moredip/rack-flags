module TeeDubFeatureFlags
  class RackMiddleware
    COOKIE_NAME = 'tee-dub-feature-flags'
    ENV_KEY = 'tee-dub-feature-flags'

    def initialize(app)
      @app = app
    end

    def call(env)
      req = Rack::Request.new(env)
      raw_flags = req.cookies[COOKIE_NAME]
      if raw_flags
        env[ENV_KEY] = FlagOverrides.from_cookie(raw_flags)
      else
        env[ENV_KEY] = FlagOverrides.create_empty
      end

      status,headers,body = @app.call(env)
      res = Rack::Response.new(body,status,headers)

      if flags = env[ENV_KEY]
        res.set_cookie( COOKIE_NAME, flags.to_cookie )
      else
        res.delete_cookie( COOKIE_NAME )
      end

      res.finish
    end

  end
end
