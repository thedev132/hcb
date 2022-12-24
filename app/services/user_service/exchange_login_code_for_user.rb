# frozen_string_literal: true

module UserService
  class ExchangeLoginCodeForUser
    def initialize(user_id:, login_code:, sms: false)
      @user_id = user_id
      @login_code = login_code
      @sms = sms
    end

    def run
      raise ::Errors::InvalidLoginCode, error_message if exchange_login_code_resp[:errors].present? || exchange_login_code_resp[:error].present?

      user = User.find_or_initialize_by(email: remote_email)
      user.api_access_token = remote_access_token
      # User `admin_at` was previously coupled to the Hack Club API. This is no
      # longer the case.
      user.admin_at = Time.now if Rails.env.development? # Make all users admin in development mode
      user.save!

      user.reload
    end

    private

    def exchange_login_code_resp
      @exchange_login_code_resp ||= ::Partners::HackclubApi::ExchangeLoginCode.new(
        user_id: @user_id,
        login_code: @login_code,
        sms: @sms
      ).run
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

    def error_message
      "Invalid login code"
    end

  end
end
