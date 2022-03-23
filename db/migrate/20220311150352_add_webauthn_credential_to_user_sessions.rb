# frozen_string_literal: true

class AddWebauthnCredentialToUserSessions < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_reference :user_sessions, :webauthn_credential, index: { algorithm: :concurrently }
  end

end
