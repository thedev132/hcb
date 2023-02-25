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

      # rubocop:disable Naming/VariableNumber
      if Flipper.enabled?(:login_code_2023_02_21)
        user = exchange_login_code_resp[:user]
      else
        user = User.find_or_initialize_by(email: remote_email)
      end
      # rubocop:enable Naming/VariableNumber

      user.api_access_token = remote_access_token
      # User `admin_at` was previously coupled to the Hack Club API. This is no
      # longer the case.
      user.admin_at = Time.now if Rails.env.development? # Make all users admin in development mode
      user.save!

      user.reload
    end

    private

    def exchange_login_code_resp
      # rubocop:disable Naming/VariableNumber
      if Flipper.enabled?(:login_code_2023_02_21)
        if @sms
          @exchange_login_code_resp ||= exchange_login_code_by_sms
        else
          @exchange_login_code_resp ||= exchange_login_code_by_email
        end
      else
        @exchange_login_code_resp ||= ::Partners::HackclubApi::ExchangeLoginCode.new(
          user_id: @user_id,
          login_code: @login_code,
          sms: @sms
        ).run
      end
      # rubocop:enable Naming/VariableNumber
    end

    def exchange_login_code_by_sms
      login_code = @login_code.delete("-")
      user = User.find(@user_id)

      if TwilioVerificationService.new.check_verification_token(user.phone_number, login_code)
        { user: user }
      else
        { errors: 'login code is invalid' }
      end
    end

    def exchange_login_code_by_email
      login_code = LoginCode.active.find_by(code: @login_code.delete("-"), user_id: @user_id)

      return { errors: 'not found' } if login_code.nil?
      return { errors: 'invalid' } if login_code.created_at < (Time.current - 15.minutes)

      login_code.update(used_at: Time.current)

      { user: login_code.user }
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
