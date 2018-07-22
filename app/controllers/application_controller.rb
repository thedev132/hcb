class ApplicationController < ActionController::Base
  include Pundit
  include SessionsHelper

  protect_from_forgery

  # Force usage of Pundit on actions
  after_action :verify_authorized

  rescue_from ApiService::UnauthorizedError, with: :user_not_authenticated
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  # This being called probably means that the User's access token has expired.
  def user_not_authenticated
    sign_out
    flash[:error] = 'You were signed out. Please re-login.'
    redirect_to root_path
  end

  def user_not_authorized
    flash[:error] = 'You are not authorized to perform this action.'
    redirect_to(root_path)
  end
end
