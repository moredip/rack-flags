module RackFlags
  def self.for_env(env)
    env[RackMiddleware::ENV_KEY] || Reader.blank_reader
  end

  def self.resources_path_for(subpath)
    File.expand_path( File.join('../../resources', subpath), __FILE__ )
  end
end

require 'rack-flags/reader'
require 'rack-flags/cookie_codec'
require 'rack-flags/config'
require 'rack-flags/rack_middleware'
require 'rack-flags/admin_app'