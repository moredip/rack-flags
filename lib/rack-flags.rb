require 'rack-flags/reader'
require 'rack-flags/cookie_codec'
require 'rack-flags/config'
require 'rack-flags/rack_middleware'
require 'rack-flags/admin_app'

module RackFlags
  def self.for_env(env)
    env[RackMiddleware::ENV_KEY] || Reader.blank_reader
  end
end
