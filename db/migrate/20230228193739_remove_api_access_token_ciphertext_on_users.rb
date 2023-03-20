# frozen_string_literal: true

class RemoveApiAccessTokenCiphertextOnUsers < ActiveRecord::Migration[7.0]
  safety_assured do
    remove_column :users, :api_access_token_ciphertext
  end

end
