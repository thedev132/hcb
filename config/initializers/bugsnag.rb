Bugsnag.configure do |config|
  config.api_key = Rails.application.credentials.bugsnag
  config.notify_release_stages = ['production']
end
