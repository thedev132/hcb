# frozen_string_literal: true

module UserService
  class EnrollSmsAuth
    def initialize(user)
      @user = user
    end

    # Starts the phone number verification by sending a challenge text
    def start_verification
      # This shouldn't be possible because to enroll in SMS auth, your phone number should be reformatted already
      # doing this here to be safe.
      raise ArgumentError.new("phone number for user: #{@user.id} not in E.164 format") unless @user.phone_number =~ /\A\+[1-9]\d{1,14}\z/

      # rubocop:disable Naming/VariableNumber
      if Flipper.enabled?(:login_code_2023_02_21)
        TwilioVerificationService.new.send_verification_request(@user.phone_number)
      else
        # updates the user's phone number on the Bank API
        ::BankApiService.req(
          "put",
          "/v1/users/#{current_user[:id]}",
          { phone_number: @user.phone_number },
          @user.api_access_token
        )

        ::BankApiService.req("post", "/v1/users/sms_auth", email: @user.email)
      end
      # rubocop:enable Naming/VariableNumber
    end

    # Completing the phone number verification by checking that exchanging code works
    def complete_verification(verification_code)
      # rubocop:disable Naming/VariableNumber
      if Flipper.enabled?(:login_code_2023_02_21)
        begin
          verified = TwilioVerificationService.new.check_verification_token(@user.phone_number, verification_code)
        rescue Twilio::REST::RestError
          raise ::Errors::InvalidLoginCode, "invalid login code"
        end
        raise ::Errors::InvalidLoginCode, "invalid login code" if !verified
      else
        begin
          resp = ::BankApiService.req(
            "post",
            "/v1/users/#{current_user[:id]}/sms_exchange_login_code",
            login_code: verification_code
          )
        rescue ::BankApiService::UnauthorizedError
          raise ::Errors::InvalidLoginCode, "invalid login code"
        end

        # Make sure we re-copy the api access token or else our Bank API is not gonna be happy
        @user.api_access_token = resp[:auth_token]
      end
      # rubocop:enable Naming/VariableNumber

      # save all our fields
      @user.phone_number_verified = true
      @user.use_sms_auth = true
      @user.save!
    end

    def enroll_sms_auth
      raise SMSEnrollmentError("user has no phone number") if @user.phone_number.blank?
      raise SMSEnrollmentError("user has not verified phone number") unless @user.phone_number_verified

      @user.use_sms_auth = true
      @user.save!
    end

    def disable_sms_auth
      @user.use_sms_auth = false
      @user.save!
    end

    private

    class SMSEnrollmentError < StandardError
    end

    def current_user
      ::BankApiService.req(
        "get",
        "/v1/users/current",
        nil,
        @user.api_access_token
      )
    end

  end
end
