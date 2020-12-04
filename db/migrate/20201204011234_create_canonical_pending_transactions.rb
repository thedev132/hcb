class CreateCanonicalPendingTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :canonical_pending_transactions do |t|
      t.date :date, null: false
      t.text :memo, null: false
      t.integer :amount_cents, null: false

      t.references :raw_pending_stripe_transaction, foreign_key: true, index: { name: :index_canonical_pending_txs_on_raw_pending_stripe_tx_id }

      t.timestamps
    end
  end
end
