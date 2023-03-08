# frozen_string_literal: true

module LoginCodeService
  class Request
    def initialize(email:, ip_address:, user_agent:, sms: false)
      @email = email
      @sms = sms
      @ip_address = ip_address
      @user_agent = user_agent
    end

    def run
      user = User.find_or_initialize_by(email: @email.downcase)

      if @sms
        send_login_code_by_sms(user)
      else
        send_login_code_by_email(user)
      end
    end

    def send_login_code_by_sms(user)
      return { error: "no phone number provided" } if user.phone_number.empty?

      TwilioVerificationService.new.send_verification_request(user.phone_number)

      {
        id: user.id,
        email: user.email,
        status: "login code sent"
      }
    end

    def send_login_code_by_email(user)
      login_code = user.login_codes.new(
        ip_address: @ip_address,
        user_agent: @user_agent
      )

      resp = {}
      if user.save
        LoginCodeMailer.send_code(user.email, login_code.pretty).deliver_later

        resp = {
          id: user.id,
          email: user.email,
          status: "login code sent"
        }
      elsif !user.valid?
        resp[:error] = user.errors
      end
      resp
    end

  end
end
