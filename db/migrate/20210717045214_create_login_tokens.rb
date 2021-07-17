# frozen_string_literal: true

class CreateLoginTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :login_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.text :token, null: false
      t.datetime :expiration_at, null: false

      t.timestamps
    end

    add_index :login_tokens, :token, unique: true
  end
end
