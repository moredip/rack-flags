module TeeDub module FeatureFlags
  class FullFlagView
    attr_reader :full_flag

    def initialize(full_flag)
      @full_flag = full_flag
    end

    def default
      full_flag.default ? 'On' : 'Off'
    end

    def checked_attribute_for(state)
      @checked_states ||= generate_checked_states

      @checked_states[state]
    end

    def generate_checked_states
      checked_states = Hash.new('')
      checked_states[selected_state] = 'checked'
      checked_states
    end

    def selected_state
      case full_flag.override
      when nil then :default
      when true then :on
      else :off
      end
    end

  end

  class AdminApp
    def call(env)
      reader = TeeDub::FeatureFlags.for_env(env)

      response = Rack::Response.new
      response['Content-Type'] = 'text/html'

      response.write <<-EOH
        <h2>Tee Dub Feature Flag Admin</h2>
        <form method="post">
      EOH

      reader.full_flags.each do |flag|
        full_flag_view = FullFlagView.new(flag)

        response.write <<-EOH
          <section data-flag-name="#{flag.name}">
            <h3>#{flag.name}</h3>
            <p>#{flag.description}</p>
            <label class="default">
              Default (#{full_flag_view.default})
              <input type="radio" name="#{flag.name}" value="default" #{full_flag_view.checked_attribute_for(:default)}/>
            </label>

            <label class="on">
              On
              <input type="radio" name="#{flag.name}" value="on" #{full_flag_view.checked_attribute_for(:on)}/>
            </label>

            <label class="off">
              Off
              <input type="radio" name="#{flag.name}" value="off" #{full_flag_view.checked_attribute_for(:off)}/>
            </label>
          </section>
        EOH
      end

      response.write <<-EOH
          <hr/>
          <input type="submit" value="Update flags"/>
        </form>
      EOH
      response.finish
    end

  end
end end