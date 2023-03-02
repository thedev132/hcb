# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(File.join(File.dirname(__FILE__), ".ruby-version")).strip

gem "dotenv-rails", groups: [:development, :test]

gem "rails", "~> 7.0.4"

# Drivers

gem "pg" # database
gem "redis" # for caching, Sidekiq, etc.
gem "hiredis"
gem "sidekiq" # background jobs
gem "sidekiq-cron" # run sidekiq jobs at scheduled intervals
gem "puma" # app server

gem "image_processing"
gem "mini_magick"


# JS/Assets

gem "jsbundling-rails"
gem "terser" # JS compressor
gem "sassc-rails"
gem "jquery-rails"
gem "react-rails"
gem "turbo-rails"

gem "invisible_captcha"

gem "local_time" # client-side timestamp converter for cache-safe rendering

gem "country_select"


# External Services & APIs

gem "httparty"
gem "faraday"

gem "plaid", "~> 6.0"
gem "stripe"

gem "aws-sdk-s3", require: false

gem "airrecord" # Airtable API for internal operations

gem "twilio-ruby" # SMS notifications

gem "lob"

gem "docusign_esign" # DocuSign API

gem "google-apis-admin_directory_v1" # GSuite

# net-http is required in top level Gemfile to avoid these warnings
# /usr/local/lib/ruby/2.7.0/net/protocol.rb:66: warning: already initialized constant Net::ProtocRetryError
# /bundle/ruby/2.7.0/gems/net-protocol-0.1.3/lib/net/protocol.rb:68: warning: previous definition of ProtocRetryError was here
# https://github.com/ruby/net-imap/issues/16
gem "net-http"
gem "uri", "0.10.0" # lock to default version of uri from Ruby 2.7


# Model Spices & Addons

gem "pg_search" # full-text search

gem "lockbox" # encrypt sensitive data
gem "blind_index" # needed to query and/or guarantee uniqueness for encrypted fields with lockbox

gem "aasm" # state machine

gem "paper_trail" # track changes to models
gem "acts_as_paranoid" # enables soft deletions

gem "friendly_id" # slugs
gem "hashid-rails" # obfuscate IDs in URLs

gem "active_storage_validations" # file validations
gem "validates_email_format_of" # email address validation
gem "phonelib" # phone number validation


# Calculations & Other Fun Financial Stuff

gem "money-rails"
gem "monetize"

gem "rounding"

gem "business_time"

gem "caxlsx"
gem "caxlsx_rails"
gem "rubyzip"

gem "wicked_pdf" # HTML to PDF conversion


# Rack/Request Stuff

gem "rack-cors" # manage CORS

gem "rack-attack" # rate limiting
gem "browser" # browser detection

# Pagination
gem "kaminari"
gem "api-pagination"


# Feature Flags & Experimentation

gem "flipper"
gem "flipper-active_record"
gem "flipper-ui"

gem "scientist" # helps refactor code for critical paths with confidence
# gem "lab_tech" # collects data from scientist experiments
gem "table_print" # pretty prints tables in console (used with lab_tech)


# Other

gem "pundit" # implements authorization policies

# API V3
gem "grape"
gem "grape-entity" # For Grape::Entity ( https://github.com/ruby-grape/grape-entity )
gem "grape-kaminari"
gem "grape-route-helpers"
gem "grape-swagger"
gem "grape-swagger-entity", "~> 0.3"

gem "redcarpet" # markdown parsing

gem "namae" # multi-cultural human name parser
gem "premailer-rails" # css to inline styles for emails
gem "safely_block"
gem "selenium-webdriver", "4.0.0.beta3"
gem "strong_migrations" # protects against risky migrations
gem "swagger-blocks"
gem "xxhash" # fast hashing

gem "webauthn"

gem "ahoy_matey" # analytics
gem "airbrake" # exception tracking
gem "blazer" # business intelligence tool/dashboard

gem "geo_pattern" # create procedurally generated patterns for Cards
gem "comma" # CSV generation

gem "chronic" # time/date parsing
gem "rinku", require: "rails_rinku" # auto-linking URLs in text

gem "geocoder" # lookup lat/lng for Stripe Cards shipment tracking

gem "rqrcode" # QR code generation

gem "rack-mini-profiler"
gem "stackprof" # provides flamegraphs for rack-mini-profiler

gem "brakeman" # static security vulnerability scanner

gem "awesome_print" # pretty print objects in console
gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
gem "dry-validation"

gem "bootsnap", require: false # reduces boot times through caching; required in config/boot.rb

group :production do
  gem "skylight"
  gem "newrelic_rpm"

  # gem "heroku-deflater" # compression

  # Heroku language runtime metrics
  # https://devcenter.heroku.com/articles/language-runtime-metrics-ruby#add-the-barnes-gem-to-your-application
  gem "barnes"
end

group :test do
  # Test data
  gem "factory_bot_rails"
  gem "faker"
end

group :development, :test do
  gem "erb_lint", require: false
  gem "rubocop"
  gem "relaxed-rubocop"

  gem "rspec-rails"

  gem "webdrivers"

  # Lets you set a breakpoint with a REPL using binding.pry
  gem "pry-byebug"
  gem "pry-rails"
end

group :development, :staging do
  gem "query_count"
end

group :development do
  gem "annotate" # comment models with database schema

  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "listen"
  gem "web-console"

  gem "letter_opener_web" # preview emails

  gem "wkhtmltopdf-binary", "0.12.3" # version must match the wkhtmltopdf Heroku buildpack version (0.12.3 by default)

  # Ruby language server
  gem "solargraph", require: false
  gem "solargraph-rails", require: false

  gem "htmlbeautifier", require: false # for https://marketplace.visualstudio.com/items?itemName=tomclose.format-erb

  gem "foreman"
end
