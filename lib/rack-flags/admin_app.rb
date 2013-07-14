require 'erb'

module RackFlags
  class FullFlagPresenter

    def initialize(full_flag)
      @full_flag = full_flag
    end

    def default
      @full_flag.default ? 'On' : 'Off'
    end

    def name
      @full_flag.name
    end

    def description
      @full_flag.description
    end

    def checked_attribute_for(state)
      state == selected_state ? 'checked' : ''
    end

    private

      def selected_state
        case @full_flag.override
        when nil then :default
        when true then :on
        else :off
        end
      end

  end

  class AdminApp
    def call(env)
      request = Rack::Request.new(env)

      if request.path_info.chomp("/").empty?
        handle_root(request)
      else
        handle_non_root(request)
      end
    end

    private

      def handle_root(request)
        case 
        when request.get? then handle_root_get(request)
        when request.post? then handle_root_post(request)
        else
          not_allowed
        end
      end

      def handle_root_get(request)
        reader = RackFlags.for_env(request.env)

        template = ERB.new(resource('index.html.erb'))


        flag_presenters = reader.full_flags.map{ |flag| FullFlagPresenter.new(flag) }
        view_model = OpenStruct.new( 
          :css_href => "#{request.path}/style.css",
          :flags => flag_presenters
        )

        [
          200, 
          {'Content-Type'=>'text/html'}, 
          [template.result( view_model.instance_eval{ binding } )]
        ]
      end

      def handle_root_post(request)
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

      def handle_non_root(request)
        Rack::File.new( RackFlags.path_for_resource('admin_app') ).call(request.env)
      end

      def not_allowed
        [405, {}, ['405 - METHOD NOT ALLOWED']]
      end

      def flag_value_for(form_param_flag_state)
        flag_states = {
            on: true,
            off: false,
            default: nil
        }
        flag_states[form_param_flag_state.to_sym]
      end

      def resource_root
        RackFlags.path_for_resource('admin_app')
      end

      def resource(filename)
        File.read(RackFlags.path_for_resource(File.join('admin_app',filename)))
      end

  end
end
