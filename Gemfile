# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(File.join(File.dirname(__FILE__), ".ruby-version")).strip

gem "dotenv-rails", groups: [:development, :test]

gem "rails", "~> 7.0.4"

gem "puma", "~> 4.3" # app server

gem "pg", ">= 0.18", "< 2.0" # database
gem "redis", "~> 4.0" # for caching, jobs, etc.
gem "hiredis"
gem "sidekiq" # background jobs
gem "sidekiq-cron", "~> 1.1" # run Sidekiq jobs at scheduled intervals

gem "image_processing", "~> 1.2"
gem "mini_magick"


gem "jsbundling-rails", "~> 1.0"
gem "terser", "~> 1.1" # JS compressor
gem "sassc-rails"
gem "jquery-rails"
gem "react-rails"
gem "turbo-rails", "~> 1.4"

gem "invisible_captcha"
gem "local_time" # client-side timestamp converter for cache-safe rendering
gem "country_select", "~> 8.0"


gem "httparty" # web requests
gem "faraday" # wen requests

gem "increase", "~> 0.3.1"
gem "stripe", "8.2.0"
gem "plaid", "~> 6.0"

gem "aws-sdk-s3", require: false

gem "airrecord", "~> 1.0" # Airtable API for internal operations

gem "twilio-ruby" # SMS notifications

gem "lob"

gem "docusign_esign", "~> 3.13" # DocuSign API

gem "google-apis-admin_directory_v1", "~> 0.23.0" # GSuite

# net-http is required in top level Gemfile to avoid these warnings
# /usr/local/lib/ruby/2.7.0/net/protocol.rb:66: warning: already initialized constant Net::ProtocRetryError
# /bundle/ruby/2.7.0/gems/net-protocol-0.1.3/lib/net/protocol.rb:68: warning: previous definition of ProtocRetryError was here
# https://github.com/ruby/net-imap/issues/16
gem "net-http"
gem "uri", "0.10.0" # lock to default version of uri from Ruby 2.7


gem "pg_search" # full-text search

gem "lockbox" # encrypt sensitive data
gem "blind_index" # needed to query and/or guarantee uniqueness for encrypted fields with lockbox

gem "aasm" # state machine

gem "paper_trail" # track changes to models
gem "acts_as_paranoid", "~> 0.8.1" # enables soft deletions

gem "friendly_id", "~> 5.2.0" # slugs
gem "hashid-rails", "~> 1.0" # obfuscate IDs in URLs

gem "active_storage_validations" # file validations
gem "validates_email_format_of" # email address validations
gem "phonelib" # phone number validations

gem "money-rails"
gem "monetize"
gem "rounding"

gem "business_time"

gem "wicked_pdf" # HTML to PDF conversion


gem "rack-cors" # manage CORS
gem "rack-attack" # rate limiting
gem "browser", "~> 5.3" # browser detection

# Pagination
gem "kaminari"
gem "api-pagination"


gem "flipper" # feature flags
gem "flipper-active_record"
gem "flipper-ui"

gem "scientist" # helps refactor code for critical paths with confidence
# gem "lab_tech" # collects data from scientist experiments
gem "table_print" # pretty prints tables in console (used with lab_tech)


gem "pundit" # implements authorization policies

# API V3
gem "grape"
gem "grape-entity" # For Grape::Entity ( https://github.com/ruby-grape/grape-entity )
gem "grape-kaminari"
gem "grape-route-helpers"
gem "grape-swagger"
gem "grape-swagger-entity", "~> 0.3"

gem "maildown" # markdown for views
gem "redcarpet" # markdown parsing

gem "namae" # multi-cultural human name parser
gem "premailer-rails" # css to inline styles for emails
gem "safely_block"
gem "selenium-webdriver", "4.0.0.beta3"
gem "strong_migrations" # protects against risky migrations
gem "swagger-blocks"
gem "xxhash" # fast hashing

gem "webauthn", "~> 2.5"

gem "ahoy_matey" # analytics
gem "airbrake" # exception tracking
gem "blazer" # business intelligence tool/dashboard

gem "geo_pattern", "~> 1.4" # create procedurally generated patterns for Cards
gem "comma", "~> 4.6" # CSV generation

gem "chronic" # time/date parsing
gem "rinku", require: "rails_rinku" # auto-linking URLs in text

gem "geocoder" # lookup lat/lng for Stripe Cards shipment tracking

gem "rqrcode" # QR code generation

gem "rack-mini-profiler", "~> 3.0"
gem "stackprof" # provides flamegraphs for rack-mini-profiler

gem "brakeman" # static security vulnerability scanner

gem "awesome_print" # pretty print objects in console
gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
gem "dry-validation"

gem "bootsnap", ">= 1.4.4", require: false # reduces boot times through caching; required in config/boot.rb


gem "mrsk", github: "mrsked/mrsk", ref: "83dc82661b8a02dd1fbb0ee91261104cee127862" # deployments - locking to recent commit to get changes until new release
# net-ssh (used by mrsk) needs these:
gem "bcrypt_pbkdf"
gem "ed25519"

group :production do
  gem "skylight"

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

  gem "rspec-rails", "~> 5.0.0"

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
  gem "listen", "~> 3.2"
  gem "web-console", ">= 3.3.0"

  gem "letter_opener_web" # preview emails

  gem "wkhtmltopdf-binary", "0.12.3" # version must match the wkhtmltopdf Heroku buildpack version (0.12.3 by default)

  # Ruby language server
  gem "solargraph", require: false
  gem "solargraph-rails", "~> 0.2.0", require: false

  gem "htmlbeautifier", require: false # for https://marketplace.visualstudio.com/items?itemName=tomclose.format-erb

  gem "foreman"
end
