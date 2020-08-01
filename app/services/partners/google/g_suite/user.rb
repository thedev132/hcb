require "google/apis/site_verification_v1"

module Partners
  module Google
    module GSuite
      class User
        include Partners::Google::GSuite::Shared::DirectoryClient

        def initialize(email:)
          @email = email
        end

        def run
          directory_client.get_user(@email, projection: 'full')
        end
      end
    end
  end
end
