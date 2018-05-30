module StripeService
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
