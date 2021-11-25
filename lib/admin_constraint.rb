# frozen_string_literal: true

# Used to restrict access of Sidekiq to admins. See routes.rbfor more info.
class AdminConstraint
  include Rails.application.routes.url_helpers

  def matches?(request)
    cookies = ActionDispatch::Cookies::CookieJar.build(request, request.cookies)
    session_token = cookies.encrypted[:session_token]

    return false unless session_token.present?

    potential_session = UserSession.find_by(session_token: session_token)
    if potential_session
      return potential_session.user && potential_session.user.admin?
    end
    false
  rescue BankApiService::UnauthorizedError
    false # user is not logged in
  end
end
