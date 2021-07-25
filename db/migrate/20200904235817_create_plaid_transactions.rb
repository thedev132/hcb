# frozen_string_literal: true

class CreatePlaidTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :plaid_transactions do |t|
      t.text :plaid_account_id
      t.text :plaid_item_id
      t.text :plaid_transaction_id
      t.jsonb :plaid_transaction
      t.integer :amount_cents
      t.date :date_posted

      t.timestamps
    end
  end
end
