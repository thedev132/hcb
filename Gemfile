# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(File.join(File.dirname(__FILE__), ".ruby-version")).strip

gem "dotenv-rails", groups: [:development, :test]

# gem 'sassc-rails' # required for rails 6

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 7.0.4"
# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
# Use Puma as the app server
gem "puma", "~> 4.3"
# Use SCSS for stylesheets
gem "sassc-rails"
# Include jQuery
gem "jquery-rails"
# Use Terser as compressor for JavaScript assets
gem "terser", "~> 1.1"
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "react-rails"
# See https://github.com/rails/execjs#readme for more supported runtimes
# Due to a bug in mini_racer >=0.5.0 running on GitHub Actions, we've had to
# roll back to mini_racer 0.4.0: https://github.com/rubyjs/mini_racer/issues/218.
gem "mini_racer", "~> 0.4.0", platforms: :ruby
# Turbo makes navigating your web application faster. Read more: https://github.com/hotwired/turbo
gem "turbo-rails", "~> 1.4"
# Use Redis adapter to run Action Cable in production
gem "redis", "~> 4.0"
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem "httparty"

# For Plaid integration
gem "plaid", "~> 6.0"
# And Stripe...
gem "stripe", "8.2.0"
# Increase (https://increase.com/)
gem "increase", "~> 0.3.1"
# And AWS usage...
gem "aws-sdk-s3", require: false
# And our own API...
gem "faraday"
# net-http is required in top level Gemfile to avoid these warnings
# /usr/local/lib/ruby/2.7.0/net/protocol.rb:66: warning: already initialized constant Net::ProtocRetryError
# /bundle/ruby/2.7.0/gems/net-protocol-0.1.3/lib/net/protocol.rb:68: warning: previous definition of ProtocRetryError was here
# https://github.com/ruby/net-imap/issues/16
gem "net-http"
gem "uri", "0.10.0" # lock to default version of uri from Ruby 2.7

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.4", require: false

# Allow un-deletions
gem "acts_as_paranoid", "~> 0.8.1"
# friendly ids in URLs
gem "friendly_id", "~> 5.2.0"

# Email validation!
gem "validates_email_format_of"
# Phone validation!
gem "phonelib"

# Rounding dates
gem "rounding"

# Checks!
gem "lob"

# Jobs!
gem "sidekiq"

# Authorization!
gem "pundit"

# Helper for automatically adding links to rendered text
gem "rinku", require: "rails_rinku"
# Allow Markdown for views
gem "maildown"

# Generating QR codes for donation pages
gem "rqrcode"

# Manage CORS
gem "rack-cors"

# Converting HTML to PDFs
gem "wicked_pdf"

# Markdown in Comments
gem "redcarpet"

# Localize to user's timezone
gem "local_time"
# Calculate dates with business days
gem "business_time"

# Image Processing for ActiveStorage
gem "image_processing", "~> 1.2"
gem "mini_magick"

# Pagination
gem "api-pagination"
gem "kaminari"

# Google (GSuite)
gem "google-apis-admin_directory_v1", "~> 0.23.0"

# Validations on receipt files
gem "active_storage_validations"

# Feature-flags
gem "flipper"
gem "flipper-active_record"
gem "flipper-ui"

# Send SMS messages
gem "twilio-ruby"

group :development, :test do
  gem "erb_lint", require: false
  gem "relaxed-rubocop"
  gem "rspec-rails", "~> 5.0.0"
  gem "rubocop"
  gem "webdrivers"

  # Static analysis tool that devs can manually trigger
  # https://github.com/presidentbeef/brakeman
  gem "brakeman"
end

group :development, :staging do
  # Prints out how many SQL queries were executed
  gem "query_count"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "listen", "~> 3.2"
  gem "web-console", ">= 3.3.0"
  # Preview emails
  gem "letter_opener_web"
  # Generate PDFs from HTML. Version must match the wkhtmltopdf Heroku buildpack version (0.12.3 by default)
  gem "wkhtmltopdf-binary", "0.12.3"
  # Ruby language server
  gem "solargraph", require: false
  gem "solargraph-rails", "~> 0.2.0", require: false
  # For https://marketplace.visualstudio.com/items?itemName=tomclose.format-erb
  gem "htmlbeautifier", require: false

  # adds comments to models with database fields
  gem "annotate"

  # for running webpack-dev-server and rails server together via Procfile
  gem "foreman"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  # gem 'capybara', '>= 2.15', '< 4.0'
  # gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  # gem 'chromedriver-helper'

  # For creating test data in the database
  gem "factory_bot_rails"
  # For initializing fake values
  gem "faker"
end

group :development, :test do
  # Lets you set a breakpoint with a REPL using binding.pry
  gem "pry-byebug"
  gem "pry-rails"
end

gem "mrsk", github: "mrsked/mrsk", ref: "83dc82661b8a02dd1fbb0ee91261104cee127862" # deployments - locking to recent commit to get changes until new release
# net-ssh (used by mrsk) needs these
gem "bcrypt_pbkdf"
gem "ed25519"

group :production do
  # Performance tracking
  gem "skylight"

  # Enable compression in production
  # gem "heroku-deflater"

  # Heroku language runtime metrics
  # https://devcenter.heroku.com/articles/language-runtime-metrics-ruby#add-the-barnes-gem-to-your-application
  gem "barnes"
end

gem "aasm" # state machine
gem "ahoy_matey" # event engine
gem "airbrake" # exception tracking
gem "awesome_print"
gem "blazer" # business intelligence tool/dashboard
gem "blind_index" # needed to query and/or guarantee uniqueness for  lockbox encrypted fields
gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
gem "chronic"
gem "dry-validation"
gem "geocoder" # lookup lat/lng for Stripe Cards shipment tracking
gem "grape" # API v3
gem "grape-entity" # For Grape::Entity ( https://github.com/ruby-grape/grape-entity )
gem "grape-kaminari"
gem "grape-route-helpers"
gem "grape-swagger" # API v3
gem "grape-swagger-entity", "~> 0.3"
gem "hashid-rails", "~> 1.0"
gem "hiredis"
gem "invisible_captcha"
gem "lockbox" # encrypt partner stripe keys and other sensitive fields
gem "monetize" # for handling human input for money amounts
gem "money-rails" # back cent fields as money objects
gem "namae" # multi-cultural human name parser
gem "paper_trail" # track changes on models
gem "pg_search"
gem "premailer-rails" # css to inline styles for emails
gem "rack-attack"
gem "safely_block"
gem "selenium-webdriver", "4.0.0.beta3"
gem "sidekiq-cron", "~> 1.1" # run sidekiq scheduled tasks
gem "strong_migrations" # protects against risky migrations that could cause application harm on deploy
gem "swagger-blocks"
gem "xxhash" # fast hashing

gem "docusign_esign", "~> 3.13"

gem "webauthn", "~> 2.5"

gem "browser", "~> 5.3"

gem "geo_pattern", "~> 1.4" # for procedurally generated patterns on Cards

gem "comma", "~> 4.6"


gem "jsbundling-rails", "~> 1.0"

gem "rack-mini-profiler", "~> 3.0"
gem "stackprof" # Used with `rack-mini-profiler` to provide flamegraphs

gem "country_select", "~> 8.0"

gem "airrecord", "~> 1.0"

# temporarily remove lab_tech because it's not compatible with rails 7
# gem "lab_tech" # Integrates `scientist` with ActiveRecord for experiment data collection
gem "scientist" # Refactor testing for critical paths
gem "table_print" # Pretty print tables in the console (used with `lab_tech`)
