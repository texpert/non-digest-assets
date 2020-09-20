require_relative 'boot'

require 'rails'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

Bundler.require(*Rails.groups)

module RailsTestApp
  class Application < Rails::Application
    config.load_defaults 6.0
  end
end
