# frozen_string_literal: true

module LoginCodeService
  class Request
    def initialize(email:, ip_address:, user_agent:, sms: false)
      @email = email.downcase
      @sms = sms
      @ip_address = ip_address
      @user_agent = user_agent
    end

    def run
      user = User.find_or_initialize_by(email: @email)

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
      user.save if user.new_record?
      if user.new_record? && !user.save
        return { error: user.errors }
      end

      login_code = user.login_codes.create(
        ip_address: @ip_address,
        user_agent: @user_agent
      )

      LoginCodeMailer.send_code(user.email, login_code.pretty).deliver_now

      {
        id: user.id,
        email: user.email,
        status: "login code sent"
      }
    end

  end
end
