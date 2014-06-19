require 'rr'
require 'pry'
require 'rack'
require 'rack/test'
require 'rspec/its'
require 'rspec/collection_matchers'

require_relative '../lib/rack-flags'

RSpec.configure do |config|
  config.mock_with :rr
  # or if that doesn't work due to a version incompatibility
  # config.mock_with RR::Adapters::Rspec
end
