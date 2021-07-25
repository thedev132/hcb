# frozen_string_literal: true

class CreateBankAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :bank_accounts do |t|
      t.text :plaid_access_token
      t.text :plaid_item_id
      t.text :plaid_account_id
      t.text :name
      t.text :official_name

      t.timestamps
    end
  end
end
