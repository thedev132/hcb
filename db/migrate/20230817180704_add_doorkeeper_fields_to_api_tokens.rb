# frozen_string_literal: true

class AddDoorkeeperFieldsToApiTokens < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    safety_assured do
      change_table :api_tokens do |t|
        t.references :application, index: { algorithm: :concurrently }
        t.datetime :revoked_at
        t.string   :refresh_token
        t.integer  :expires_in
        t.string   :scopes
      end
    end
  end

end
