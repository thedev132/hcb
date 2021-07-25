# frozen_string_literal: true

class CreateRawPendingOutgoingAchTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :raw_pending_outgoing_ach_transactions do |t|
      t.text :ach_transaction_id
      t.integer :amount_cents
      t.date :date_posted
      t.string :state

      t.timestamps
    end
  end
end
