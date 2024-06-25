# frozen_string_literal: true

stripe_environment = Rails.env.production? ? :live : :test

# update as needed, we specify explicitly in code to avoid inter-branch API version conflicts
Stripe.api_version = "2019-12-03"
Stripe.api_key = Rails.application.credentials.stripe[stripe_environment][:secret_key]
