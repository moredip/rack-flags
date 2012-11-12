module TeeDubFeatureFlags
  class AdminApp
    def call(env)

      defaults = Defaults.load
      overrides = FlagOverrides.from_env(env)

      response = Rack::Response.new
      response.write("<h2>Tee Dub Feature Flag Admin</h2>")
      defaults.flags.values.each do |flag|
        response.write("<h3>#{flag.name}</h3>")
      end
      response.finish
    end
  end
end
