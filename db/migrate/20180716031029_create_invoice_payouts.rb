# frozen_string_literal: true

class CreateInvoicePayouts < ActiveRecord::Migration[5.2]
  def change
    create_table :invoice_payouts do |t|
      t.text :stripe_payout_id
      t.bigint :amount
      t.datetime :arrival_date
      t.boolean :automatic
      t.text :stripe_balance_transaction_id
      t.datetime :stripe_created_at
      t.text :currency
      t.text :description
      t.text :stripe_destination_id
      t.text :failure_stripe_balance_transaction_id
      t.text :failure_code
      t.text :failure_message
      t.text :method
      t.text :source_type
      t.text :statement_descriptor
      t.text :status
      t.text :type

      t.timestamps
    end
    add_index :invoice_payouts, :stripe_payout_id, unique: true
    add_index :invoice_payouts, :stripe_balance_transaction_id, unique: true
    add_index :invoice_payouts, :failure_stripe_balance_transaction_id, unique: true
  end
end
