# frozen_string_literal: true

module StripeService
  # stripe enforces that statement descriptors are limited to this long
  STATEMENT_DESCRIPTOR_CHAR_LIMIT = 22

  def self.mode
    if Rails.env.production?
      :live
    else
      :test
    end
  end

  def self.publishable_key
    Rails.application.credentials.stripe[self.mode][:publishable_key]
  end

  def self.secret_key
    Rails.application.credentials.stripe[self.mode][:secret_key]
  end

  def self.construct_webhook_event(payload, sig_header, signing_secret_key = :primary)
    signing_secret = Rails.application.credentials.dig(:stripe, self.mode, :webhook_signing_secrets, signing_secret_key)

    # Don't check signatures if a signing secret wasn't provided
    # TODO: don't allow a blank signing secret in production
    if signing_secret.blank?
      Stripe::Event.construct_from(JSON.parse(payload, symbolize_names: true))
    else
      Stripe::Webhook.construct_event(payload, sig_header, signing_secret)
    end
  end

  Stripe.api_key = self.secret_key
  include Stripe
end
