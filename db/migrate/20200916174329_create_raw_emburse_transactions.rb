# frozen_string_literal: true

class CreateRawEmburseTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :raw_emburse_transactions do |t|
      t.text :emburse_transaction_id
      t.jsonb :emburse_transaction
      t.integer :amount_cents
      t.date :date_posted
      t.string :state

      t.timestamps
    end
  end
end
