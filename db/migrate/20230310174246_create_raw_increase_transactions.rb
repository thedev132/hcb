# frozen_string_literal: true

class CreateRawIncreaseTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :raw_increase_transactions do |t|
      t.integer :amount_cents
      t.date :date_posted
      t.text :increase_transaction_id
      t.text :increase_account_id
      t.text :increase_route_id
      t.text :increase_route_type
      t.text :description

      t.index :increase_transaction_id, unique: true

      t.timestamps
    end
  end

end
