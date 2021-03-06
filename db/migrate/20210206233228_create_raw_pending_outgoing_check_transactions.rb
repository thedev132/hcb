class CreateRawPendingOutgoingCheckTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :raw_pending_outgoing_check_transactions do |t|
      t.text :lob_transaction_id
      t.jsonb :lob_transaction
      t.integer :amount_cents
      t.date :date_posted
      t.string :state

      t.timestamps
    end
  end
end
