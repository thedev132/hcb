module Partners
  module HackclubApi
    class GetUser
      def initialize(user_id:, access_token:)
        @user_id = user_id
        @access_token = access_token
      end

      def run
        ::BankApiService.req(:get, url, attrs, @access_token)
      end

      private

      def attrs
        nil
      end

      def url
        "/v1/users/#{@user_id}"
      end
    end
  end
end
