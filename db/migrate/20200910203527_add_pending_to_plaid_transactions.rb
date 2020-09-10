class AddPendingToPlaidTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :plaid_transactions, :pending, :boolean, default: false
  end
end
