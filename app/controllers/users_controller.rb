# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :signed_in_user, only: [:auth, :login_code, :exchange_login_code]
  skip_after_action :verify_authorized, except: [:edit, :update]
  before_action :hide_footer

  def impersonate
    authorize current_user

    impersonate_user(User.find(params[:user_id]))

    redirect_to(params[:return_to] || root_path)
  end

  # view to log in
  def auth
    @prefill_email = params[:email] if params[:email].present?
    @return_to = params[:return_to]
  end

  # post to request login code
  def login_code
    @return_to = params[:return_to]
    @email = params[:email].downcase
    @force_use_email = params[:force_use_email]
    initialize_sms_params

    resp = ::Partners::HackclubApi::RequestLoginCode.new(email: @email, sms: @use_sms_auth).run
    if resp[:error].present?
      flash[:error] = resp[:error]
      return redirect_to auth_users_path
    end
    @user_id = resp[:id]
  end

  # post to exchange auth token for access token
  def exchange_login_code
    fingerprint_info = {
      fingerprint: params[:fingerprint],
      device_info: params[:device_info],
      os_info: params[:os_info],
      timezone: params[:timezone],
      ip: request.remote_ip
    }

    user = UserService::ExchangeLoginCodeForUser.new(
      user_id: params[:user_id],
      login_code: params[:login_code],
      sms: params[:sms]
    ).run

    sign_in(user: user, fingerprint_info: fingerprint_info)

    # Clear the flash - this prevents the error message showing up after an unsuccessful -> successful login
    flash.clear

    if user.full_name.blank? || user.phone_number.blank?
      redirect_to edit_user_path(user.slug)
    else
      return_to = params[:return_to] if params[:return_to].present? && params[:return_to].start_with?(root_url)
      redirect_to(return_to || root_path)
    end
  rescue Errors::InvalidLoginCode => e
    flash[:error] = e.message
    # Propagate the to the login_code page on invalid code
    @user_id = params[:user_id]
    @email = params[:email]
    @force_use_email = params[:force_use_email]
    initialize_sms_params
    return render "login_code", status: :unprocessable_entity
  end

  def logout
    sign_out
    redirect_to root_path
  end

  def logout_all
    sign_out_of_all_sessions
    redirect_to root_path
  end

  def logout_session
    begin
      session = UserSession.find(params[:id])
      if session.user.id != current_user.id
        Rail.logger.error "User id: #{user.id} tried to delete session #{session.id}"
        flash[:error] = "Error deleting the session"
        return
      end

      session.destroy
      flash[:success] = "Deleted session!"
    rescue ActiveRecord::RecordNotFound => e
      flash[:error] = "Session is not found"
    end
    redirect_to root_path
  end

  def edit
    @user = params[:id] ? User.friendly.find(params[:id]) : current_user
    @onboarding = @user.full_name.blank?
    show_impersonated_sessions = admin_signed_in? || current_session.impersonated?
    @sessions = show_impersonated_sessions ? @user.user_sessions : @user.user_sessions.not_impersonated
    authorize @user
  end

  def update
    @user = User.friendly.find(params[:id])
    authorize @user

    if @user.update(user_params)
      flash[:success] = "Updated your profile!"
      redirect_to root_path
    else
      render "edit"
    end
  end

  def delete_profile_picture
    @user = User.friendly.find(params[:user_id])
    authorize @user

    @user.profile_picture.purge_later

    flash[:success] = "Switched back to your Gravatar."
    redirect_to edit_user_path(@user.slug)
  end

  def start_sms_auth_verification
    authorize current_user
    svc = UserService::EnrollSmsAuth.new(current_user)
    svc.start_verification
    render json: { message: "started verification successfully" }, status: :ok
  end

  def complete_sms_auth_verification
    authorize current_user
    params.require(:code)
    svc = UserService::EnrollSmsAuth.new(current_user)
    svc.complete_verification(params[:code])
    render json: { message: "completed verification successfully" }, status: :ok
  rescue ::Errors::InvalidLoginCode
    render json: { error: "invalid login code" }, status: :forbidden
  end

  def toggle_sms_auth
    user = current_user
    authorize user
    svc = UserService::EnrollSmsAuth.new(current_user)
    if user.use_sms_auth
      svc.disable_sms_auth
    else
      svc.enroll_sms_auth
    end
    render json: { useSmsAuth: user.use_sms_auth }, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(
      :full_name,
      :phone_number,
      :profile_picture,
      :pretend_is_not_admin,
      :sessions_reported
    )
  end

  def initialize_sms_params
    return if @force_use_email

    user = User.find_by(email: @email)
    if user&.use_sms_auth
      @use_sms_auth = true
      @phone_last_four = user.phone_number.last(4)
    end
  end

end
