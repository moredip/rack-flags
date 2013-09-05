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

    def section_class
      @full_flag.override.nil? || @full_flag.override == @full_flag.default ? '' : 'override'
    end

    def default_icon_for(state)
      state == default_state ? '<span class="default-icon">D</span>' : ''
    end

    private

      def selected_state
        override = @full_flag.override
        if override.nil?
          state_for @full_flag.default
        else
          state_for override
        end
      end

      def default_state
        state_for @full_flag.default
      end

      def state_for(attribute)
        case attribute
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

      response.set_cookie(
        CookieCodec::COOKIE_KEY, 
        value: CookieCodec.new.generate_cookie_from(overrides), 
        path: '/',
        expires: cookie_expiration
      )
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

      def cookie_expiration
        # store overrides in the cookie for around for ~5 years from the last time they were modified
        Time.new( Time.now.year + 5 )
      end

  end
end
