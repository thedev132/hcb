# frozen_string_literal: true

Geocoder.configure(
  timeout: 2,

  ip_lookup: :ipinfo_io,
  ipinfo_io: {
    api_key: Rails.application.credentials.ipinfo_io[:api_key],
  },

  cache: Redis.new,
  cache_options: {
    # ipinfo.io rate limits at 50,000/month with a free account (about 70
    # requests per hour)
    expiration: 2.days,
  }
)
