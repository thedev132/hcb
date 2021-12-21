# frozen_string_literal: true

module SessionsHelper
  def impersonate_user(user)
    sign_in(user: user, impersonate: true)
  end

  # DEPRECATED - begin to start deprecating and ultimately replace with sign_in_and_set_cookie
  def sign_in(user:, fingerprint_info: {}, impersonate: false)
    session_token = SecureRandom.urlsafe_base64
    cookies.encrypted[:session_token] = { value: session_token, expires: 30.days.from_now  }
    user.user_sessions.create(
      session_token: session_token,
      fingerprint: fingerprint_info[:fingerprint],
      device_info: fingerprint_info[:device_info],
      os_info: fingerprint_info[:os_info],
      timezone: fingerprint_info[:timezone],
      ip: fingerprint_info[:ip]
    )

    # probably a better place to do this, but we gotta assign any pending
    # organizer position invites - see that class for details
    OrganizerPositionInvite.pending_assign.where(email: user.email).find_each do |invite|
      invite.update(user: user)
    end

    if impersonate
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

  def organizer_signed_in?
    @organizer_signed_in ||= ((signed_in? && @event&.users&.include?(current_user)) || admin_signed_in?)
  end

  # Ensure api authorized when fetching current user is removed
  def current_user(_ensure_api_authorized = true)
    if !@current_user and current_session
      @current_user ||= current_session.user
    end

    return nil unless @current_user

    @current_user
  end

  def current_session
    # Find a valid session token within all the ones currently in the table for this particular user
    potential_session = UserSession.find_by(session_token: cookies.encrypted[:session_token])

    return nil unless potential_session

    # check if the potential session is still valid
    # If the session is greater than 30 days then the current user is no longer valid
    # (.abs) is added for easier testing when fast-forwarding created_at times
    if (Time.now - potential_session.created_at).abs > 30.days
      potential_session.destroy
      return nil
    end

    potential_session
  end

  def signed_in_user
    unless signed_in?
      redirect_to auth_users_path
    end
  end

  def signed_in_admin
    unless admin_signed_in?
      redirect_to auth_users_path, flash: { error: "You’ll need to sign in as an admin." }
    end
  end

  def sign_out
    current_user(false).user_sessions.find_by(session_token: cookies.encrypted[:session_token]).destroy if current_user(false)
    cookies.delete(:session_token)
    self.current_user = nil
  end

  def sign_out_of_all_sessions
    # Destroy all the sessions
    current_user(false).user_sessions.destroy_all if current_user(false)
    cookies.delete(:session_token)
    self.current_user = nil
  end
end
