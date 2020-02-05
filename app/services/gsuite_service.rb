class GsuiteService
  require "google/apis/admin_directory_v1"
  require "googleauth"
  require "googleauth/stores/file_token_store"

  include Singleton

  OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
  SCOPE = [Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_USER, Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_ORGUNIT]

  # this is a hack to work with the google library's requirement that tokens must be in files
  TOKEN_FILE = Tempfile.new("token")
  TOKEN_FILE << Rails.application.credentials.gsuite[:token]
  TOKEN_FILE.rewind
  TOKEN_FILE.close

  Google::Apis.logger.level = Rails.env.production? ? Logger::FATAL : Logger::DEBUG

  def authorize
    client_id = Google::Auth::ClientId.from_hash JSON.parse(Rails.application.credentials.gsuite[:client_id_json])
    token_store = Google::Auth::Stores::FileTokenStore.new file: TOKEN_FILE.path
    authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
    user_id = "default"
    credentials = authorizer.get_credentials user_id
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

  def client
    service = Google::Apis::AdminDirectoryV1::DirectoryService.new
    service.client_options.application_name = "Hack Club Bank"
    service.client_options.log_http_requests = false
    service.authorization = authorize # calling the above method for authorization

    service
  end

  def get_ou_name_from_event(event)
    "##{event.id} #{event.name}"
  end

  def get_gsuite_user(email)
    begin
      client.get_user(
        email,
        projection: 'full'
      )
    rescue Google::Apis::ClientError
      nil
    end
  end

  def delete_gsuite_user(email)
    begin
      client.delete_user(email)
      true
    rescue Google::Apis::ClientError
      false
    end
  end

  # makes a new GSuite user & also makes a new org unit for the event if it doesn't exist
  # returns nil if the domain isn't found, throws an error otherwise
  def create_event_gsuite_user(first_name, last_name, email, recovery_email, temp_password, org_unit_name)
    if get_organizational_unit("Events/#{org_unit_name}") == nil
      create_organizational_unit(org_unit_name, '/Events')
    end

    user_struct = Google::Apis::AdminDirectoryV1::User.new(
      {
        name: {
          'given_name': first_name,
          'family_name': last_name
        },
        password: temp_password,
        primary_email: email,
        recovery_email: recovery_email,
        org_unit_path: "/Events/#{org_unit_name}",
        change_password_at_next_login: true
      }
    )

    begin
      client.insert_user(user_struct)
    rescue Google::Apis::ClientError => e
      reason = JSON.parse(e.body)['error']['errors'][0]['message']
      return nil if reason == "Domain not found."

      raise e
    end
  end

  # gets an org unit
  # returns nil if something doesn't work
  def get_organizational_unit(ou)
    begin
      # 'my_customer' is a hard-coded default-provided user that Google
      # specifies. It must be this string and not any other name.
      client.get_org_unit('my_customer', ou)
    rescue Google::Apis::ClientError # this means it doesn't exist basically
      nil
    end
  end

  def create_organizational_unit(name, parent_ou_path)
    org_unit_struct = Google::Apis::AdminDirectoryV1::OrgUnit.new(
      {
        name: name,
        parent_org_unit_path: parent_ou_path
      }
    )
    # 'my_customer' is a hard-coded default-provided user that Google
    # specifies. It must be this string and not any other name.
    client.insert_org_unit('my_customer', org_unit_struct)
  end

  # sets a GSuite user's password to something specified & forces them to change it on next login
  def reset_gsuite_user_password(email, password)
    update_user_struct = Google::Apis::AdminDirectoryV1::User.new(
      change_password_at_next_login: true,
      password: password
    )
    client.update_user(email, update_user_struct)
  end

  def toggle_gsuite_user_suspension(email, suspend)
    update_user_struct = Google::Apis::AdminDirectoryV1::User.new(
      suspended: suspend
    )
    client.update_user(email, update_user_struct)
  end
end
