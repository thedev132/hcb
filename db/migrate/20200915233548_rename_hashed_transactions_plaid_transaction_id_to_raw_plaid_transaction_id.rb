class RenameHashedTransactionsPlaidTransactionIdToRawPlaidTransactionId < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      rename_column :hashed_transactions, :plaid_transaction_id, :raw_plaid_transaction_id
    end
  end
end
