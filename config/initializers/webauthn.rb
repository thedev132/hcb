# frozen_string_literal: true

WebAuthn.configure do |config|
  if Rails.env.staging?
    # Use the Heroku review app's origin
    heroku_app_name = ENV["HEROKU_APP_NAME"]
    config.origin = "https://#{heroku_app_name}.herokuapp.com"
  else
    config.origin = Rails.application.routes.default_url_options[:host]
  end

  config.rp_name = "Hack Club Bank"
end
