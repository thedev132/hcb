require_relative 'boot'

require 'rack/throttle'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bank
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Customize generators...
    config.generators do |g|
      g.test_framework false
    end

    config.react.camelize_props = true

    config.add_autoload_paths_to_load_path

    # Use Sidekiq
    config.active_job.queue_adapter = :sidekiq

    config.autoload_paths << "#{config.root}/lib"
    config.eager_load_paths << "#{config.root}/lib"

    # Middleware
    config.middleware.use Rack::Throttle::Interval
  end
end
