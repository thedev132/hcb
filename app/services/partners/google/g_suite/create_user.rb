# frozen_string_literal: true

module Partners
  module Google
    module GSuite
      class CreateUser
        include Partners::Google::GSuite::Shared::DirectoryClient

        def initialize(given_name:, family_name:, password:, primary_email:, recovery_email:,
                       org_unit_path:)
          @given_name = given_name
          @family_name = family_name
          @password = password
          @primary_email = primary_email
          @recovery_email = recovery_email

          @org_unit_path = org_unit_path
        end

        def run
          directory_client.insert_user(user_object)
        end

        private

        def user_object
          ::Google::Apis::AdminDirectoryV1::User.new({
            org_unit_path: @org_unit_path,

            name: {
              'given_name': @given_name,
              'family_name': @family_name
            },
            password: @password,
            primary_email: @primary_email,
            recovery_email: @recovery_email,
            change_password_at_next_login: true
          })
        end
      end
    end
  end
end
