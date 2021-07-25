# frozen_string_literal: true

module Partners
  module Google
    module GSuite
      class User
        include Partners::Google::GSuite::Shared::DirectoryClient

        def initialize(email:)
          @email = email
        end

        def run
          directory_client.get_user(@email, projection: "full")
        end
      end
    end
  end
end
