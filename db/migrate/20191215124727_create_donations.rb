# frozen_string_literal: true

class CreateDonations < ActiveRecord::Migration[5.2]
  def change
    create_table :donations do |t|
      t.text :email
      t.text :name
      t.string :url_hash
      t.integer :amount
      t.integer :amount_received
      t.string :status
      t.string :stripe_client_secret
      t.string :stripe_payment_intent_id
      t.datetime :payout_creation_queued_at
      t.datetime :payout_creation_queued_for
      t.string :payout_creation_queued_job_id
      t.integer :payout_creation_balance_net
      t.integer :payout_creation_balance_stripe_fee
      t.datetime :payout_creation_balance_available_at

      t.references :event, foreign_key: true
      t.references :payout, foreign_key: { to_table: :donation_payouts }
      t.references :fee_reimbursement, foreign_key: true

      t.timestamps
    end
  end
end
