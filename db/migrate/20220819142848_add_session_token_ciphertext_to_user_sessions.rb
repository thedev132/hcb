# frozen_string_literal: true

class AddSessionTokenCiphertextToUserSessions < ActiveRecord::Migration[6.1]
  def change
    add_column :user_sessions, :session_token_ciphertext, :text
  end

end
