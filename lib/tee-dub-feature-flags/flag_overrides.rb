module TeeDubFeatureFlags
  class FlagOverrides
    def self.from_cookie(flag_string)
      new(flag_string)
    end

    def self.create_empty
      new('')
    end

    def self.from_env(env)
      env[RackMiddleware::ENV_KEY]
    end

    def initialize( raw_flag_string )
      @flags = {}
      raw_flag_string.split(' ').each do |flag|
        if negative_flag = flag[/^!(.+)/,1]
          unset(negative_flag)
        else
          set(flag)
        end
      end
    end

    def to_cookie
      @flags.map do |flag_name,set_on|
        if set_on
          flag_name.to_s
        else
          '!'+flag_name.to_s
        end
      end.join(' ')
    end

    def all_flags
      @flags.dup.freeze
    end

    def set(flag_name)
      @flags[flag_name.to_sym] = true
    end

    def unset(flag_name)
      @flags[flag_name.to_sym] = false
    end
  end
end
