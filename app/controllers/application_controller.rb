class ApplicationController < ActionController::Base
  include SessionsHelper

  def self.auth
    if Rails.env.production?
      Rails.application.credentials.auth[:live]
    else
      Rails.application.credentials.auth[:test]
    end
  end

  http_basic_authenticate_with name: auth[:username], password: auth[:password]
end
