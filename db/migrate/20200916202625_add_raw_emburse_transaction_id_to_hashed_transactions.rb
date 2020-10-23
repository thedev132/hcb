class AddRawEmburseTransactionIdToHashedTransactions < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_column :hashed_transactions, :raw_emburse_transaction_id, :integer
  end
end
