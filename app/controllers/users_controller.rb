# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :signed_in_user, only: [:auth, :auth_submit, :choose_login_preference, :set_login_preference, :webauthn_options, :webauthn_auth, :login_code, :exchange_login_code]
  skip_before_action :redirect_to_onboarding, only: [:edit, :update, :logout]
  skip_after_action :verify_authorized, except: [:edit, :update]
  before_action :set_shown_private_feature_previews, only: [:edit, :edit_featurepreviews, :edit_security, :edit_admin]

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

  def auth_submit
    @email = params[:email]&.downcase
    user = User.find_by(email: @email)

    has_webauthn_enabled = user&.webauthn_credentials&.any?
    login_preference = session[:login_preference]

    if !has_webauthn_enabled || login_preference == "email"
      redirect_to login_code_users_path, status: 307
    else
      session[:auth_email] = @email
      redirect_to choose_login_preference_users_path
    end
  end

  def choose_login_preference
    @email = session[:auth_email]
    return redirect_to auth_users_path if @email.nil?

    session.delete :login_preference
  end

  def set_login_preference
    @email = params[:email]
    remember = params[:remember] == "1"

    case params[:login_preference]
    when "email"
      session[:login_preference] = "email" if remember
      redirect_to login_code_users_path, status: 307
    when "webauthn"
      # This should never happen, because WebAuthn auth is handled on the frontend
      redirect_to choose_login_preference_users_path
    end
  end

  # post to request login code
  def login_code
    @return_to = params[:return_to]
    @email = params.require(:email)&.downcase
    @force_use_email = params[:force_use_email]

    initialize_sms_params

    resp = LoginCodeService::Request.new(email: @email, sms: @use_sms_auth, ip_address: request.ip, user_agent: request.user_agent).run

    if resp[:error].present?
      flash[:error] = resp[:error]
      return redirect_to auth_users_path
    end
    @user_id = resp[:id]

    @webauthn_available = User.find_by(email: @email)&.webauthn_credentials&.any?

  rescue ActionController::ParameterMissing
    flash[:error] = "Please enter an email address."
    redirect_to auth_users_path
  end

  def webauthn_options
    return head :not_found if !params[:email]

    session[:auth_email] = params[:email]

    return head :not_found if params[:require_webauthn_preference] && session[:login_preference] != "webauthn"

    user = User.find_by(email: params[:email])

    return head :not_found if !user || user.webauthn_credentials.empty?

    options = WebAuthn::Credential.options_for_get(
      allow: user.webauthn_credentials.pluck(:webauthn_id),
      user_verification: "discouraged"
    )

    session[:webauthn_challenge] = options.challenge

    render json: options
  end

  def webauthn_auth
    user = User.find_by(email: params[:email])

    if !user
      return redirect_to auth_users_path
    end

    webauthn_credential = WebAuthn::Credential.from_get(JSON.parse(params[:credential]))

    stored_credential = user.webauthn_credentials.find_by!(webauthn_id: webauthn_credential.id)

    begin
      webauthn_credential.verify(
        session[:webauthn_challenge],
        public_key: stored_credential.public_key,
        sign_count: stored_credential.sign_count
      )

      stored_credential.update!(sign_count: webauthn_credential.sign_count)

      fingerprint_info = {
        fingerprint: params[:fingerprint],
        device_info: params[:device_info],
        os_info: params[:os_info],
        timezone: params[:timezone],
        ip: request.remote_ip
      }

      session[:login_preference] = "webauthn" if params[:remember] == "true"

      sign_in(user:, fingerprint_info:, webauthn_credential: stored_credential)

      redirect_to(params[:return_to] || root_path)

    rescue WebAuthn::SignCountVerificationError, WebAuthn::Error => e
      redirect_to auth_users_path, flash: { error: "Something went wrong." }
    rescue ActiveRecord::RecordInvalid => e
      redirect_to auth_users_path, flash: { error: e.record.errors&.full_messages&.join(". ") }
    end
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

    sign_in(user:, fingerprint_info:)

    # Clear the flash - this prevents the error message showing up after an unsuccessful -> successful login
    flash.clear

    if user.full_name.blank? || user.phone_number.blank?
      redirect_to edit_user_path(user.slug)
    else
      redirect_to(params[:return_to] || root_path)
    end
  rescue Errors::InvalidLoginCode => e
    flash.now[:error] = "Invalid login code!"
    # Propagate the to the login_code page on invalid code
    @user_id = params[:user_id]
    @email = params[:email]
    @force_use_email = params[:force_use_email]
    initialize_sms_params
    return render :login_code, status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = e.record.errors&.full_messages&.join(". ")
    redirect_to auth_users_path
  end

  def logout
    sign_out
    redirect_to root_path
  end

  def logout_all
    sign_out_of_all_sessions
    redirect_to edit_user_path(current_user), flash: { success: "Success" }
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

  def receipt_report
    ReceiptReportJob::Send.perform_later(current_user.id, force_send: true)
    flash[:success] = "Receipt report generating. Check #{current_user.email}"
    redirect_to settings_previews_path
  end

  FEATURE_CONFETTI_EMOJIS = {
    receipt_bin_2023_04_07: %w[🧾 🗑️ 💰],
    receipt_report_2023_04_19: %w[🧾 📧],
    turbo_2023_01_23: %w[🚀 ⚡ 🏎️ 💨],
    sms_receipt_notifications_2022_11_23: %w[📱 🧾 🔔 💬],
  }.freeze

  def enable_feature
    @user = current_user
    @feature = params[:feature]
    authorize @user
    if Flipper.enable_actor(@feature, @user)
      confetti!(emojis: FEATURE_CONFETTI_EMOJIS[@feature.to_sym])
      flash[:success] = "Opted into beta"
    else
      flash[:error] = "Error while opting into beta"
    end
    redirect_back fallback_location: settings_previews_path
  end

  def disable_feature
    @user = current_user
    @feature = params[:feature]
    authorize @user
    if Flipper.disable_actor(@feature, @user)
      flash[:success] = "Opted out of beta"
    else
      flash[:error] = "Error while opting out of beta"
    end
    redirect_back fallback_location: settings_previews_path
  end

  def edit
    @user = params[:id] ? User.friendly.find(params[:id]) : current_user
    @onboarding = @user.onboarding?
    show_impersonated_sessions = admin_signed_in? || current_session.impersonated?
    @sessions = show_impersonated_sessions ? @user.user_sessions : @user.user_sessions.not_impersonated
    authorize @user
  end

  def edit_address
    @user = params[:id] ? User.friendly.find(params[:id]) : current_user
    redirect_to edit_user_path(@user) unless @user.stripe_cardholder
    @onboarding = @user.full_name.blank?
    show_impersonated_sessions = admin_signed_in? || current_session.impersonated?
    @sessions = show_impersonated_sessions ? @user.user_sessions : @user.user_sessions.not_impersonated
    authorize @user
  end

  def edit_featurepreviews
    @user = params[:id] ? User.friendly.find(params[:id]) : current_user
    @onboarding = @user.full_name.blank?
    show_impersonated_sessions = admin_signed_in? || current_session.impersonated?
    @sessions = show_impersonated_sessions ? @user.user_sessions : @user.user_sessions.not_impersonated
    authorize @user
  end

  def edit_security
    @user = params[:id] ? User.friendly.find(params[:id]) : current_user
    @onboarding = @user.full_name.blank?
    show_impersonated_sessions = admin_signed_in? || current_session.impersonated?
    @sessions = show_impersonated_sessions ? @user.user_sessions : @user.user_sessions.not_impersonated
    authorize @user
  end

  def edit_admin
    @user = params[:id] ? User.friendly.find(params[:id]) : current_user
    @onboarding = @user.full_name.blank?
    show_impersonated_sessions = admin_signed_in? || current_session.impersonated?
    @sessions = show_impersonated_sessions ? @user.user_sessions : @user.user_sessions.not_impersonated
    authorize @user
  end

  def update
    @user = User.friendly.find(params[:id])
    authorize @user

    if @user.admin? && params[:user][:running_balance_enabled].present?
      enable_running_balance = params[:user][:running_balance_enabled] == "1"
      if @user.running_balance_enabled? != enable_running_balance
        @user.update_attribute(:running_balance_enabled, enable_running_balance)
      end
    end

    locked = params[:user][:locked] == "1"
    if locked && @user == current_user
      flash[:error] = "As much as you might desire to, you cannot lock yourself out."
      return redirect_to admin_user_path(@user)
    elsif locked && @user.admin?
      flash[:error] = "Contact a engineer to lock out another admin."
      return redirect_to admin_user_path(@user)
    elsif locked
      @user.lock!
    else
      @user.unlock!
    end

    if @user.update(user_params)
      confetti! if !@user.seasonal_themes_enabled_before_last_save && @user.seasonal_themes_enabled? # confetti if the user enables seasonal themes

      if @user.full_name_before_last_save.blank?
        flash[:success] = "Profile created!"
        redirect_to root_path
      else
        flash[:success] = @user == current_user ? "Updated your profile!" : "Updated #{@user.first_name}'s profile!"
        redirect_back_or_to edit_user_path(@user)
      end
    else
      @onboarding = User.friendly.find(params[:id]).full_name.blank?
      show_impersonated_sessions = admin_signed_in? || current_session.impersonated?
      @sessions = show_impersonated_sessions ? @user.user_sessions : @user.user_sessions.not_impersonated
      if @user.stripe_cardholder&.errors&.any?
        flash.now[:error] = @user.stripe_cardholder.errors.first.full_message
        render :edit_address, status: :unprocessable_entity and return
      end
      render :edit, status: :unprocessable_entity
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
    # flash[:info] = "Verifying phone number"
    # redirect_to edit_user_path(current_user)
    render json: { message: "started verification successfully" }, status: :ok
  end

  def complete_sms_auth_verification
    authorize current_user
    params.require(:code)
    svc = UserService::EnrollSmsAuth.new(current_user)
    svc.complete_verification(params[:code])
    # flash[:success] = "Completed verification"
    # redirect_to edit_user_path(current_user)
    render json: { message: "completed verification successfully" }, status: :ok
  rescue ::Errors::InvalidLoginCode
    # flash[:error] = "Invalid login code"
    # redirect_to edit_user_path(current_user)
    render json: { error: "invalid login code" }, status: :forbidden
  end

  def toggle_sms_auth
    authorize current_user
    svc = UserService::EnrollSmsAuth.new(current_user)
    if current_user.use_sms_auth
      svc.disable_sms_auth
      flash[:success] = "SMS sign-in turned off"
    else
      svc.enroll_sms_auth
      flash[:success] = "SMS sign-in turned on"
    end
    redirect_to edit_user_path(current_user)
  end

  def wrapped
    redirect_to "https://bank-wrapped.hackclub.com/wrapped?user_id=#{current_user.public_id}&org_ids=#{current_user.events.transparent.map(&:public_id).join(",")}", allow_other_host: true
  end

  private

  def set_shown_private_feature_previews
    @shown_private_feature_previews = params[:classified_top_secret]&.split(",") || []
  end

  def user_params
    attributes = [
      :full_name,
      :preferred_name,
      :phone_number,
      :profile_picture,
      :pretend_is_not_admin,
      :sessions_reported,
      :session_duration_seconds,
      :receipt_report_option,
      :birthday,
      :seasonal_themes_enabled
    ]

    if @user.stripe_cardholder
      attributes << {
        stripe_cardholder_attributes: [
          :stripe_billing_address_line1,
          :stripe_billing_address_line2,
          :stripe_billing_address_city,
          :stripe_billing_address_state,
          :stripe_billing_address_postal_code,
          :stripe_billing_address_country
        ]
      }
    end

    if current_user.superadmin?
      attributes << :access_level
    end

    params.require(:user).permit(attributes)
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
