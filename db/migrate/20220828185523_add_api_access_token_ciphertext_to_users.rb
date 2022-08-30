# frozen_string_literal: true

class AddApiAccessTokenCiphertextToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :api_access_token_ciphertext, :text
  end

end
