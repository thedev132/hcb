class AddCheckTransactionIdToRawPendingOutgoingCheckTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :raw_pending_outgoing_check_transactions, :check_transaction_id, :string
  end
end
