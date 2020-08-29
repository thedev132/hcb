module UserService
  class ExchangeLoginCodeForUser
    def initialize(user_id:, login_code:)
      @user_id = user_id
      @login_code = login_code
    end

    def run
      raise ::Errors::InvalidLoginCode, error_message if exchange_login_code_resp[:errors].present?

      user = User.find_or_initialize_by(email: remote_email)
      user.api_access_token = remote_access_token 
      user.admin_at = remote_admin_at # TODO: remove admin_at as necessary from a 3rd party auth service
      user.save!

      user.reload
    end

    private

    def exchange_login_code_resp
      @exchange_login_code_resp ||= ::Partners::HackclubApi::ExchangeLoginCode.new(user_id: @user_id, login_code: @login_code).run
    end

    def get_user_resp
      @get_user_resp ||= ::Partners::HackclubApi::GetUser.new(user_id: @user_id, access_token: remote_access_token).run
    end

    def remote_access_token
      exchange_login_code_resp[:auth_token]
    end

    def remote_email
      get_user_resp[:email]
    end

    def remote_admin_at
      get_user_resp[:admin_at]
    end

    def error_message
      "Invalid login code"
    end
  end
end
