# frozen_string_literal: true

class CreateRawPendingDonationTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :raw_pending_donation_transactions do |t|
      t.integer :amount_cents
      t.date :date_posted
      t.string :state
      t.string :donation_transaction_id

      t.timestamps
    end
  end
end
