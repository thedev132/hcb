module Partners
  module HackclubApi
    class RequestLoginCode
      def initialize(email:)
        @email = email
      end

      def run
        ::ApiService.req(:post, url, attrs)
      end

      private

      def attrs
        {
          email: @email
        }
      end

      def url
        "/v1/users/auth"
      end
    end
  end
end
