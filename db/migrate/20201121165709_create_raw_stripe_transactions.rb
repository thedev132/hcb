# frozen_string_literal: true

class CreateRawStripeTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :raw_stripe_transactions do |t|
      t.text :stripe_transaction_id
      t.jsonb :stripe_transaction
      t.integer :amount_cents
      t.date :date_posted

      t.timestamps
    end
  end
end
