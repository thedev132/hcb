# frozen_string_literal: true

Increase.configure do |config|
  increase_environment = Rails.env.production? ? :production : :sandbox

  # Your Increase API Key!
  # Grab it from https://dashboard.increase.com/developers/api_keys
  config.api_key = Rails.application.credentials.dig(:increase, increase_environment, :api_key)

  # The base URL for Increase's API.
  # You can use
  # - :production (https://api.increase.com)
  # - :sandbox (https://sandbox.increase.com)
  # - or set an actual URL
  config.base_url = increase_environment

  # Whether to raise an error when the API returns a non-2XX status.
  # If disabled (false), the client will return the error response as a normal,
  # instead of raising an error.
  #
  # Learn more about...
  # - Increase's errors: https://increase.com/documentation/api#errors
  # - Error classes: https://github.com/garyhtou/increase-ruby/blob/main/lib/increase/errors.rb
  config.raise_api_errors = true # Default: true
end
