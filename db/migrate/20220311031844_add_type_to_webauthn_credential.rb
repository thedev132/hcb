# frozen_string_literal: true

class AddTypeToWebauthnCredential < ActiveRecord::Migration[6.0]
  def change
    add_column :webauthn_credentials, :authenticator_type, :integer
  end

end
