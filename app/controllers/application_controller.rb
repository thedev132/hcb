class ApplicationController < ActionController::Base
  include Pundit
  include SessionsHelper

  protect_from_forgery

  # Ensure users are signed in. Create one-off exceptions to this on routes
  # that you want to be unauthenticated with skip_before_action.
  before_action :signed_in_user

  # Force usage of Pundit on actions
  after_action :verify_authorized

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
    if request.get?
      redirect_to auth_users_path(return_to: request.url)
    else
      redirect_to auth_users_path
    end
  end

  def user_not_authorized
    flash[:error] = 'You are not authorized to perform this action.'
    if current_user || !request.get?
      redirect_to root_path
    else
      redirect_to auth_users_path(return_to: request.url)
    end
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def using_transaction_engine_v2?
    params[:v1] != 'true' && (params[:v2] == 'true' || @event.try(:transaction_engine_v2_at))
  end
  helper_method :using_transaction_engine_v2?

  def using_pending_transaction_engine?
    params[:pendingV2] || @event.try(:pending_transaction_engine_at)
  end
  helper_method :using_pending_transaction_engine?

  def set_streaming_headers
    headers["X-Accel-Buffering"] = "no"
    headers["Cache-Control"] ||= "no-cache"
    headers.delete("Content-Length")
  end
end
