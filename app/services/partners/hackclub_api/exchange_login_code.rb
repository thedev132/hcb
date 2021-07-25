# frozen_string_literal: true

module Partners
  module HackclubApi
    class ExchangeLoginCode
      def initialize(user_id:, login_code:)
        @user_id = user_id
        @login_code = login_code
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
        "/v1/users/#{@user_id}/exchange_login_code"
      end

      def clean_login_code
        @clean_login_code ||= @login_code.to_s.gsub("-", "").gsub(/\s+/, "")
      end
    end
  end
end
