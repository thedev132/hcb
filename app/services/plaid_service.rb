# frozen_string_literal: true

class PlaidService
  include Singleton

  def client_id
    Rails.application.credentials.plaid[:client_id]
  end

  def public_key
    Rails.application.credentials.plaid[:public_key]
  end

  def secret_key
    case env
    when "development"
      Rails.application.credentials.plaid[:development_secret]
    when "sandbox"
      Rails.application.credentials.plaid[:sandbox_secret]
    end
  end

  def client_name
    "Hack Club"
  end

  # env to provide to Plaid Link integration
  def env
    # Since we're only using one account & Plaid's development plan supports up
    # to 100 accounts, we're just going to stick with the development key in
    # production for now. Plaid is essentially read-only, so this also works in development.
    "development"
  end

  def client
    Plaid::Client.new(
      env: env,
      client_id: client_id,
      secret: secret_key,
      public_key: public_key
    )
  end

  def exchange_public_token(public_token)
    client.item.public_token.exchange(public_token)
  end

  # get info of currently authenticated item
  def get_auth_info(access_token)
    client.auth.get(access_token)
  end
end
