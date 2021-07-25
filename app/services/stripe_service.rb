# frozen_string_literal: true

module StripeService
  # stripe enforces that statement descriptors are limited to this long
  StatementDescriptorCharLimit = 22

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

  Stripe.api_key = self.secret_key
  include Stripe
end
