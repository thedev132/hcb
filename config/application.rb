require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bank
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Customize generators...
    config.generators do |g|
      g.test_framework false
    end

    # Use Sidekiq
    config.active_job.queue_adapter = :sidekiq

    config.autoload_paths << "#{config.root}/lib"
    config.eager_load_paths << "#{config.root}/lib"

    # Allow whitelist of origins through CORS
    config.middleware.insert_before 0, Rack::Cors do
      DOMAINS = %w{https://hackclub.com localhost}

      allow do
        origins do |source, _env|
          DOMAINS.each do |domain|
            parsed = URI.parse(source)
            domain == source || domain == parsed.host
          end
        end

        resource '*',
                 headers: :any,
                 methods: %i[get post put patch delete options head]
      end

    end
  end
end
