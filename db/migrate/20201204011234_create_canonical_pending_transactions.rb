class CreateCanonicalPendingTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :canonical_pending_transactions do |t|
      t.date :date, null: false
      t.text :memo, null: false
      t.integer :amount_cents, null: false

      t.references :raw_pending_stripe_transactions, foreign_key: true

      t.timestamps
    end
  end
end
