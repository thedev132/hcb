# frozen_string_literal: true

class CreateApiTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :api_tokens do |t|
      t.text :token_ciphertext
      t.string :token_bidx
      t.index :token_bidx, unique: true

      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end

end
