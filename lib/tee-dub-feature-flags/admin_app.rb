module TeeDubFeatureFlags
  class AdminApp
    def call(env)
      case env['REQUEST_METHOD'].upcase
      when 'POST' 
        handle_post(env)
      when 'GET' 
        handle_get(env)
      else 
        [405,{},'405 - METHOD NOT ALLOWED']
      end
    end

    private

    def handle_get(env)
      defaults = Defaults.load
      overrides = FlagOverrides.from_env(env)

      derived_flags = TeeDubFeatureFlags.derived_flags( defaults: defaults.flags.values, overrides: overrides.all_flags)

      response = Rack::Response.new
      response.write <<-EOH
        <h2>Tee Dub Feature Flag Admin</h2>
        <form method="post">
      EOH
      derived_flags.values.each do |flag|
        checked_states = generate_checked_attributes_for(flag.override)
        response.write <<-EOH
          <h3>#{flag.name}</h3>
          <p>#{flag.description}</p>
          <label>
            Default (#{bool_as_flag_desc(flag.default)})
            <input type="radio" name="#{flag.name}" value="default" #{checked_states[:default]}/>
          </label>

          <label>
            On
            <input type="radio" name="#{flag.name}" value="on" #{checked_states[:on]}/>
          </label>

          <label>
            Off
            <input type="radio" name="#{flag.name}" value="off" #{checked_states[:off]}/>
          </label>
        EOH
      end

      response.write <<-EOH
          <hr/>
          <input type="submit" value="Update flags"/>
        </form>
      EOH
      response.finish
    end

    def handle_post(env)
      flags = TeeDubFeatureFlags::FlagOverrides.from_env(env)
      req = Rack::Request.new(env)

      req.POST.each do |flag_name,flag_state|
        flags.update( flag_name, flag_as_bool(flag_state) )
      end

      [303,{'Location'=>req.script_name},'']
    end

    def generate_checked_attributes_for(state)
      states = Hash.new('')
      on_state = state_as_sym( state )
      states[on_state] = "checked"
      states
    end

    def state_as_sym(state)
      case state
      when nil then :default
      when true then :on
      else :off
      end
    end

    def bool_as_flag_desc(bool)
      bool ? 'On' : 'Off'
    end

    def flag_as_bool(flag)
      case flag.downcase
      when 'on' then true
      when 'default' then nil
      else false
      end
    end
  end
end
