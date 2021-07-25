# frozen_string_literal: true

class CreateRawPendingInvoiceTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :raw_pending_invoice_transactions do |t|
      t.string :invoice_transaction_id
      t.integer :amount_cents
      t.date :date_posted
      t.string :state

      t.timestamps
    end
  end
end
