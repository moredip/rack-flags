module TeeDub module FeatureFlags
  class FullFlagPresenter
    attr_reader :full_flag

    def initialize(full_flag)
      @full_flag = full_flag
    end

    def default
      full_flag.default ? 'On' : 'Off'
    end

    def checked_attribute_for(state)
      state == selected_state ? 'checked' : ''
    end

    private

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
      request = Rack::Request.new(env)

      case
      when request.get? then handle_get(env)
      when request.post? then handle_post(request)
      else
        not_allowed
      end
    end

    private
      def handle_get(env)
        reader = TeeDub::FeatureFlags.for_env(env)

        response = Rack::Response.new
        response['Content-Type'] = 'text/html'

        response.write <<-EOH
          <h2>Tee Dub Feature Flag Admin</h2>
          <form method="post">
        EOH

        reader.full_flags.each do |flag|
          full_flag_presenter = FullFlagPresenter.new(flag)

          response.write <<-EOH
            <section data-flag-name="#{flag.name}">
              <h3>#{flag.name}</h3>
              <p>#{flag.description}</p>
              <label class="default">
                Default (#{full_flag_presenter.default})
                <input type="radio" name="#{flag.name}" value="default" #{full_flag_presenter.checked_attribute_for(:default)}/>
              </label>

              <label class="on">
                On
                <input type="radio" name="#{flag.name}" value="on" #{full_flag_presenter.checked_attribute_for(:on)}/>
              </label>

              <label class="off">
                Off
                <input type="radio" name="#{flag.name}" value="off" #{full_flag_presenter.checked_attribute_for(:off)}/>
              </label>
            </section>
          EOH
        end

        response.write <<-EOH
            <hr/>
            <input type="submit" value="Update Flags"/>
          </form>
        EOH
        response.finish
      end

      def handle_post(request)
        overrides = request.POST.inject({}) do |overrides, (flag_name, form_param_flag_state)|
          overrides[flag_name.downcase.to_sym] = flag_value_for(form_param_flag_state)
          overrides
        end

        cookie = CookieCodec.new.generate_cookie_from(overrides)

        response = Rack::Response.new
        response.redirect(request.script_name, 303)
        response.set_cookie(CookieCodec::COOKIE_KEY, cookie)

        response.finish
      end

      def not_allowed
        [405, {}, '405 - METHOD NOT ALLOWED']
      end

      def flag_value_for(form_param_flag_state)
        flag_states = {
            on: true,
            off: false,
            default: nil
        }
        flag_states[form_param_flag_state.to_sym]
      end

  end
end end
