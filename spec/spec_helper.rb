require "rspec"
require "rack/test"
require "pry"

require_relative "../config/init"

ENV["RACK_ENV"] = "test"

RSpec.configure do |c|
  c.include Rack::Test::Methods
  c.mock_with :rspec
end

# Airbrake.configure do |config|
#   config.environment_name = "test"
# end
