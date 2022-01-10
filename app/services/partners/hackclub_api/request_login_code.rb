# frozen_string_literal: true

module Partners
  module HackclubApi
    class RequestLoginCode
      def initialize(email:, sms: false)
        @email = email
        @sms = sms
      end

      def run
        ::BankApiService.req(:post, url, attrs)
      end

      private

      def attrs
        {
          email: @email
        }
      end

      def url
        "/v1/users/#{@sms ? 'sms_' : ''}auth"
      end

    end
  end
end
