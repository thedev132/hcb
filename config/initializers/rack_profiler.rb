# frozen_string_literal: true

if Rails.env.production?
  Rack::MiniProfiler.config.start_hidden = true

  # We're using redis because we're running on multiple heroku dynos
  # With the default file storage, we ran into https://github.com/hackclub/bank/issues/3617#issuecomment-1463316993
  Rack::MiniProfiler.config.storage_options = { url: ENV["REDIS_URL"] }
  Rack::MiniProfiler.config.storage = Rack::MiniProfiler::RedisStore
end
