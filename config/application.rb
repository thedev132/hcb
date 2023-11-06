# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bank
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    if ENV["USE_PROD_CREDENTIALS"].present?
      config.credentials.content_path = Rails.root.join("config", "credentials", "production.yml.enc")
      config.credentials.key_path = Rails.root.join("config", "credentials", "production.key")
    end

    config.action_mailer.default_url_options = {
      host: Rails.application.credentials.default_url_host[:live]
    }

    # SMTP config
    config.action_mailer.smtp_settings = {
      user_name: Rails.application.credentials.smtp[:username],
      password: Rails.application.credentials.smtp[:password],
      address: Rails.application.credentials.smtp[:address],
      domain: Rails.application.credentials.smtp[:domain],
      port: Rails.application.credentials.smtp[:port],
      authentication: :plain
    }

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

    config.autoload_paths << "#{config.root}/lib"
    config.eager_load_paths << "#{config.root}/lib"
    config.eager_load_paths << "#{config.root}/spec/mailers/previews"

    config.action_view.form_with_generates_remote_forms = false

    config.exceptions_app = routes

    config.to_prepare do
      Doorkeeper::AuthorizationsController.layout "application"
    end

    config.active_storage.variant_processor = :mini_magick

    # TODO: Pre-load grape API
    # ::API::V3.compile!

  end
end
