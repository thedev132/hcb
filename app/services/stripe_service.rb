module StripeService
  def self.publishable_key
    if Rails.env.production?
      Rails.application.credentials.stripe[:live][:publishable_key]
    else
      Rails.application.credentials.stripe[:test][:publishable_key]
    end
  end

  def self.secret_key
    if Rails.env.production?
      Rails.application.credentials.stripe[:live][:secret_key]
    else
      Rails.application.credentials.stripe[:test][:secret_key]
    end
  end

  Stripe.api_key = self.secret_key
  include Stripe
end
