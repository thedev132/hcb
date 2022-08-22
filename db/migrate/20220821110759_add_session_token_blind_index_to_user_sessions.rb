# frozen_string_literal: true

class AddSessionTokenBlindIndexToUserSessions < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :user_sessions, :session_token_bidx, :string
    add_index :user_sessions, :session_token_bidx, algorithm: :concurrently
  end

end
