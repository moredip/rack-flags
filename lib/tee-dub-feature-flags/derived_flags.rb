module TeeDubFeatureFlags
  def self.derived_flags(args)
    defaults,overrides = args.values_at(:defaults,:overrides)
    
    flags = Hash.new do |hash, key|
      hash[key] = Flag.new(name:key)
    end

    defaults.each do |flag|
      flags[flag.name.to_sym] = flag
    end

    overrides.each do |flag_name,override|
      flag_name = flag_name.to_sym
      flags[flag_name] = flags[flag_name].create_overridden_flag( override )
    end

    flags
  end
end
