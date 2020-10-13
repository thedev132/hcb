class CreateHashedTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :hashed_transactions do |t|
      t.text :primary_hash
      t.text :secondary_hash

      t.references :plaid_transaction, foreign_key: true

      t.timestamps
    end
  end
end
