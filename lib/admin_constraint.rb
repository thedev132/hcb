# Used to restrict access of Sidekiq to admins. See routes.rbfor more info.
class AdminConstraint
  include Rails.application.routes.url_helpers

  def matches?(request)
    cookies = ActionDispatch::Cookies::CookieJar.build(request, request.cookies)
    session_token = cookies.encrypted[:session_token]

    return false unless session_token.present?

    user = User.has_session_token.find_by(session_token: session_token)
    user && user.admin?
  rescue BankApiService::UnauthorizedError
    false # user is not logged in
  end
end
