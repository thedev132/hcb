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
    initialize_sms_params(@email)

    resp = ::Partners::HackclubApi::RequestLoginCode.new(email: @email, sms: @use_sms_auth).run
    @user_id = resp[:id]
  end

  # post to exchange auth token for access token
  def exchange_login_code
    user = UserService::ExchangeLoginCodeForUser.new(
      user_id: params[:user_id],
      login_code: params[:login_code],
      sms: params[:sms]
    ).run

    sign_in(user)

    # Clear the flash - this prevents the error message showing up after an unsuccessful -> successful login
    flash.clear

    if user.full_name.blank? || user.phone_number.blank?
      redirect_to edit_user_path(user.slug)
    else
      redirect_to(params[:return_to] || root_path)
    end

  rescue Errors::InvalidLoginCode => e
    flash[:error] = e.message
    # Propagate the to the login_code page on invalid code
    @user_id = params[:user_id]
    @email = params[:email]
    initialize_sms_params(@email)
    return render "login_code", status: :unprocessable_entity
  end

  def logout
    sign_out
    redirect_to root_path
  end

  def edit
    @user = params[:id] ? User.friendly.find(params[:id]) : current_user
    @onboarding = @user.full_name.blank?
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

  def initialize_sms_params(email)
    user = User.find_by(email: email)
    if user&.use_sms_auth
      @use_sms_auth = true
      @phone_last_four = user.phone_number.last(4)
    end
  end
end
