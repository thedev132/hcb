class RenamePlaidTransactionsToRawPlaidTransactions < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      rename_table :plaid_transactions, :raw_plaid_transactions
    end
  end
end
