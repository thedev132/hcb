# frozen_string_literal: true

if Rails.env.production?
  Rack::MiniProfiler.config.start_hidden = true
end
