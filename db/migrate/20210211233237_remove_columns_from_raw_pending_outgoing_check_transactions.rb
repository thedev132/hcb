class RemoveColumnsFromRawPendingOutgoingCheckTransactions < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    safety_assured {
      remove_column :raw_pending_outgoing_check_transactions, :lob_transaction_id, :text
      remove_column :raw_pending_outgoing_check_transactions, :lob_transaction, :jsonb
    }
  end
end
