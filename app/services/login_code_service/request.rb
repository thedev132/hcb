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
          status: 'login code sent'
        }
      elsif !user.valid?
        resp[:error] = user.errors
      end
      resp
    end

  end
end
