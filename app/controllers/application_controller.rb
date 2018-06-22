class ApplicationController < ActionController::Base
  include Pundit
  include SessionsHelper

  def self.auth
    if Rails.env.production?
      Rails.application.credentials.auth[:live]
    else
      Rails.application.credentials.auth[:test]
    end
  end

  protect_from_forgery

  http_basic_authenticate_with name: auth[:username], password: auth[:password]

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:error] = 'You are not authorized to perform this action.'
    redirect_to(root_path)
  end
end
