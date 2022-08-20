# frozen_string_literal: true

class AddPlaidAccessTokenCiphertextToBankAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :bank_accounts, :plaid_access_token_ciphertext, :text
  end

end
