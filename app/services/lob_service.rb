class LobService
  include Singleton

  def api_key
    if Rails.env.production?
      Rails.application.credentials.lob[:production][:api_key]
    else
      Rails.application.credentials.lob[:development][:api_key]
    end
  end

  def bank_account
    if Rails.env.production?
      Rails.application.credentials.lob[:production][:bank_account_id]
    else
      Rails.application.credentials.lob[:development][:bank_account_id]
    end
  end

  def from_address
    if Rails.env.production?
      Rails.application.credentials.lob[:production][:from_address_id]
    else
      Rails.application.credentials.lob[:development][:from_address_id]
    end
  end

  def api_version
    '2018-06-05'
  end

  def client
    Lob::Client.new(
      api_key: api_key,
      api_version: api_version
    )
  end

  def add_address(description, name, address1, address2, city, state, zip, country)
    response = client.addresses.create(
      description: description,
      name: name,
      address_line1: address1,
      address_line2: address2,
      address_city: city,
      address_state: state,
      address_zip: zip,
      address_country: country,
    )
  end

  def update_address(lob_id, description, name, address1, address2, city, state, zip, country)
    client.addresses.destroy(lob_id)

    response = client.addresses.create(
      description: description,
      name: name,
      address_line1: address1,
      address_line2: address2,
      address_city: city,
      address_state: state,
      address_zip: zip,
      address_country: country,
    )
  end

  def delete_address(lob_id)
    client.addresses.destroy(lob_id)
  end
end
