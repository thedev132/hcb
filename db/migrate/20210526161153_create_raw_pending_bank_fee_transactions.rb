class CreateRawPendingBankFeeTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :raw_pending_bank_fee_transactions do |t|
      t.string :bank_fee_transaction_id
      t.integer :amount_cents
      t.date :date_posted
      t.string :state

      t.timestamps
    end
  end
end
