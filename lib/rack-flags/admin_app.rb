require 'sinatra/base'

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

  class AdminApp < Sinatra::Base
    set :public_folder, RackFlags.resources_path_for('admin_app')
    set :views,         RackFlags.resources_path_for('admin_app')

    get '/' do
      reader = RackFlags.for_env(request.env)
      flag_presenters = reader.full_flags.map{ |flag| FullFlagPresenter.new(flag) }

      erb :index, locals: {css_href: "#{request.path.chomp('/')}/style.css", flags: flag_presenters}
    end

    post '/' do
      overrides = params.inject({}) do |overrides, (flag_name, form_param_flag_state)|
        overrides[flag_name.downcase.to_sym] = flag_value_for(form_param_flag_state)
        overrides
      end

      response.set_cookie(CookieCodec::COOKIE_KEY, value: CookieCodec.new.generate_cookie_from(overrides))
      redirect to('/'), 303
    end

    private

      def flag_value_for(form_param_flag_state)
        flag_states = {
            on: true,
            off: false,
            default: nil
        }
        flag_states[form_param_flag_state.to_sym]
      end

  end
end
