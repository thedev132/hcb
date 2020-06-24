class ApplicationController < ActionController::Base
  include Pundit
  include SessionsHelper

  protect_from_forgery

  # Ensure users are signed in. Create one-off exceptions to this on routes
  # that you want to be unauthenticated with skip_before_action.
  before_action :signed_in_user

  # Force usage of Pundit on actions
  after_action :verify_authorized

  # Associate user w/ Bugsnag for error reports
  before_bugsnag_notify :add_user_info_to_bugsnag

  rescue_from ApiService::UnauthorizedError, with: :user_not_authenticated
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def hide_footer
    @hide_footer = true
  end

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

  def add_user_info_to_bugsnag
    return unless current_user

    report.user = {
      email: current_user.email,
      name: current_user.full_name,
      id: current_user.id
    }
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end
