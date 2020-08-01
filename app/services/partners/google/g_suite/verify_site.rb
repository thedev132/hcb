module Partners
  module Google
    module GSuite
      OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
      TOKEN_FILE = Tempfile.new("token")
      TOKEN_FILE << Rails.application.credentials.gsuite[:token]
      TOKEN_FILE.rewind
      TOKEN_FILE.close

      class VerifySite
        def initialize
        end

        def run
          client.list_web_resources
        end

        private

        def client
          @client ||= begin
            ::Google::Apis::SiteVerificationV1::SiteVerificationService.new.tap do |s|
              s.client_options.application_name = "Hack Club Bank"
              s.client_options.log_http_requests = false
              s.authorization = authorization
            end
          end
        end

        def authorization
          credentials = authorizer.get_credentials(user_id)

          if credentials.nil?
            url = authorizer.get_authorization_url base_url: OOB_URI
            puts "Open the following URL in the browser and enter the " \
                 "resulting code after authorization:\n" + url
            code = gets
            credentials = authorizer.get_and_store_credentials_from_code(
              user_id: user_id, code: code, base_url: OOB_URI
            )
          end
          credentials
        end

        def user_id
          "default"
        end

        def authorizer
          @authorizer ||= ::Google::Auth::UserAuthorizer.new(client_id, scope, token_store)
        end

        def scope
          [
            ::Google::Apis::SiteVerificationV1::AUTH_SITEVERIFICATION
          ]
        end

        def client_id
          @client_id ||= ::Google::Auth::ClientId.from_hash(JSON.parse(Rails.application.credentials.gsuite[:client_id_json]))
        end

        def token_store
          @token_store ||= ::Google::Auth::Stores::FileTokenStore.new file: TOKEN_FILE.path
        end
      end
    end
  end
end
