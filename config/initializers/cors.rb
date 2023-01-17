# frozen_string_literal: true

# Allow whitelist of origins through CORS

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  DOMAINS = %w{https://hackclub.com localhost}.freeze

  allow do
    origins do |source, _env|
      DOMAINS.each do |domain|
        parsed = URI.parse(source)
        domain == source || domain == parsed.host
      end
    end

    resource "/api/*",
             headers: :any,
             methods: %i[get post put patch delete options head],
             expose: ["X-Next-Page", "X-Offset", "X-Page", "X-Per-Page", "X-Prev-Page", "X-Request-Id", "X-Runtime", "X-Total", "X-Total-Pages"]

    resource "*",
             headers: :any,
             methods: %i[get post put patch delete options head]
  end
end
