source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.5'

# gem 'sassc-rails' # required for rails 6

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.3', '>= 6.0.3.2'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Use SCSS for stylesheets
gem 'sassc-rails'
# Include jQuery
gem 'jquery-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'
gem 'react-rails'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'mini_racer', platforms: :ruby
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5.2.0'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

gem 'httparty'

# For Plaid integration
gem 'plaid', '~> 6.0'
# And Stripe...
gem 'stripe'
# And AWS usage...
gem 'aws-sdk-s3', require: false
# And our own API...
gem 'faraday'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

# Allow un-deletions
gem 'acts_as_paranoid', '~> 0.6.0'
# friendly ids in URLs
gem 'friendly_id', '~> 5.2.0'

# Email validation!
gem 'validates_email_format_of'
# Phone validation!
gem 'phonelib'

# Rounding dates
gem 'rounding'

# Checks!
gem 'lob'

# Jobs!
gem 'sidekiq'

# Authorization!
gem 'pundit'

# Helper for automatically adding links to rendered text
gem 'rinku', require: 'rails_rinku'
# Allow Markdown for views
gem 'maildown'

# Generating QR codes for donation pages
gem 'rqrcode'

# For Excel data exports... the custom ref is from
# https://github.com/straydogstudio/axlsx_rails/blob/ce5b69e4ac46f4a84f4b9194d01080f6f626fbcd/README.md
gem 'rubyzip', '>= 1.2.1'
gem 'caxlsx'
gem 'caxlsx_rails'

# Manage CORS
gem 'rack-cors'

# Converting HTML to PDFs
gem 'wicked_pdf'

# Markdown in Comments
gem 'redcarpet'

# Localize to user's timezone
gem 'local_time'
# Calculate dates with business days
gem 'business_time'

# Image Processing for ActiveStorage
gem 'mini_magick'

# Pagination
gem 'kaminari'
gem 'api-pagination'

# Google (GSuite)
gem 'google-api-client'

# Validations on receipt files
gem 'active_storage_validations'

group :development, :test do
  gem 'rspec-rails', '~> 4.0.1'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Preview emails
  gem 'letter_opener_web'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  # gem 'capybara', '>= 2.15', '< 4.0'
  # gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  # gem 'chromedriver-helper'
end

group :production do
  # Performance tracking
  gem 'skylight'

  # Enable compression in production
  gem 'heroku-deflater'
end

gem 'aasm' # state machine
gem 'airbrake' # exception tracking
gem 'blazer' # business intelligence tool/dashboard
gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
gem 'geocoder' # lookup lat/lng for Stripe Cards shipment tracking
gem 'money-rails' # back cent fields as money objects 
gem 'namae' # multi-cultural human name parser
gem 'paper_trail' # track changes on models
gem 'selenium-webdriver'
gem 'sidekiq-cron', '~> 1.1' # run sidekiq scheduled tasks
gem 'strong_migrations' # protects against risky migrations that could cause application harm on deploy
gem 'xxhash' # fast hashing
