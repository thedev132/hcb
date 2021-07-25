# frozen_string_literal: true

class CreateRawPendingPartnerDonationTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :raw_pending_partner_donation_transactions do |t|
      t.text :partner_donation_transaction_id
      t.integer :amount_cents
      t.date :date_posted
      t.string :state

      t.timestamps
    end
  end
end
