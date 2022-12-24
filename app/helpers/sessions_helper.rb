# frozen_string_literal: true

module SessionsHelper
  SESSION_DURATION_OPTIONS = {
    "1 hour"  => 1.hour.to_i,
    "1 day"   => 1.day.to_i,
    "3 days"  => 3.days.to_i,
    "7 days"  => 7.days.to_i,
    "14 days" => 14.days.to_i,
    "30 days" => 30.days.to_i
  }.freeze

  def impersonate_user(user)
    sign_in(user: user, impersonate: true)
  end

  # DEPRECATED - begin to start deprecating and ultimately replace with sign_in_and_set_cookie
  def sign_in(user:, fingerprint_info: {}, impersonate: false, webauthn_credential: nil)
    session_token = SecureRandom.urlsafe_base64
    expiration_at = Time.now + user.session_duration_seconds
    cookies.encrypted[:session_token] = { value: session_token, expires: expiration_at }
    user_session = user.user_sessions.create!(
      session_token: session_token,
      fingerprint: fingerprint_info[:fingerprint],
      device_info: fingerprint_info[:device_info],
      os_info: fingerprint_info[:os_info],
      timezone: fingerprint_info[:timezone],
      ip: fingerprint_info[:ip],
      webauthn_credential: webauthn_credential,
      expiration_at: expiration_at
    )

    if impersonate
      user_session.impersonated_by = current_user
      user_session.save
      @current_user = user
      @current_user
    else
      self.current_user = user
    end
  end

  def signed_in?
    !current_user.nil?
  end

  def admin_signed_in?
    signed_in? && current_user&.admin?
  end

  def current_user=(user)
    @current_user = user
  end

  def organizer_signed_in?(event = @event)
    @organizer_signed_in ||= Hash.new do |h, event_key|
      h[event_key] = (signed_in? && event_key&.users&.include?(current_user)) || admin_signed_in?
    end
    @organizer_signed_in[event]
  end

  # Ensure api authorized when fetching current user is removed
  def current_user(_ensure_api_authorized = true)
    if !@current_user && current_session
      @current_user ||= current_session.user
    end

    return nil unless @current_user

    @current_user
  end

  def current_session
    return @current_session if defined?(@current_session)

    # Find a valid session token within all the ones currently in the table for this particular user
    @current_session = UserSession.find_by(session_token: cookies.encrypted[:session_token])

    return nil unless @current_session

    # check if the potential session is still valid
    # If the session is greater than the expiration duration then the current
    # user is no longer valid.
    if Time.now > @current_session.expiration_at
      @current_session.set_as_peacefully_expired
      @current_session.destroy
      return nil
    end

    @current_session
  end

  def signed_in_user
    unless signed_in?
      if request.fullpath == "/"
        redirect_to auth_users_path
      else
        redirect_to auth_users_path(return_to: request.original_url)
      end
    end
  end

  def signed_in_admin
    unless admin_signed_in?
      redirect_to auth_users_path, flash: { error: "You’ll need to sign in as an admin." }
    end
  end

  def sign_out
    current_user(false)
      &.user_sessions
      &.find_by(session_token: cookies.encrypted[:session_token])
      &.set_as_peacefully_expired
      &.destroy

    cookies.delete(:session_token)
    self.current_user = nil
  end

  def sign_out_of_all_sessions
    # Destroy all the sessions except the current session
    current_user(false)
      &.user_sessions
      &.where&.not(id: current_session.id)
      &.destroy_all
  end
end
