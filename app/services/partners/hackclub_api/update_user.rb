# frozen_string_literal: true

module Partners
  module HackclubApi
    class UpdateUser
      def initialize(access_token, phone_number: nil)
        @access_token = access_token
        @phone_number = phone_number
      end

      def run
        return if Rails.env.test?

        current_user = ::BankApiService.req(
          "get",
          "/v1/users/current",
          nil,
          @access_token
        )
        ::BankApiService.req(
          "put",
          "/v1/users/#{current_user[:id]}",
          params,
          @access_token
        )
      end

      private

      def params
        obj = {}
        obj[:phone_number] = @phone_number unless @phone_number.nil?
        raise ArgumentError.new("empty update hash, must provide at least one fields") if obj.empty?

        obj
      end

    end
  end
end
