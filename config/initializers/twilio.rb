# frozen_string_literal: true

Rails.application.configure do
  # Verify Twilio webhooks
  config.middleware.use Rack::TwilioWebhookAuthentication, Rails.application.credentials.twilio[:auth_token], '/twilio/webhook'
end
