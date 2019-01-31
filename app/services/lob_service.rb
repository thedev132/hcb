class Lob
  include Singleton

  def api_key
    case env
    when 'development'
      Rails.application.credentials.lob[:development_key]
    when 'production'
      Rails.application.credentials.plaid[:production_key]
    end
  end

  def client
    Lob::Client.new(
      env: env,
      client_id: client_id,
      secret: secret_key,
      public_key: public_key
    )
  end
end