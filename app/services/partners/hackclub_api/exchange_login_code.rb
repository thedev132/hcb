# frozen_string_literal: true

module Partners
  module HackclubApi
    class ExchangeLoginCode
      def initialize(user_id:, login_code:, sms: false)
        @user_id = user_id
        @login_code = login_code
        @sms = sms
      end

      def run
        ::BankApiService.req(:post, url, attrs, raise_on_unauthorized: false)
      end

      private

      def attrs
        {
          login_code: clean_login_code
        }
      end

      def url
        "/v1/users/#{@user_id}/#{@sms ? 'sms_' : ''}exchange_login_code"
      end

      def clean_login_code
        @clean_login_code ||= @login_code.to_s.gsub("-", "").gsub(/\s+/, "")
      end
    end
  end
end
