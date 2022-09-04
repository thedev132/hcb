# frozen_string_literal: true

class DropPlaidAccessTokenFromBankAccounts < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :bank_accounts, :plaid_access_token
    end
  end

end
