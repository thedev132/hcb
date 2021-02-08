class AddRawPendingOutgoingCheckTransactionToCanonicalPendingTransactions < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_reference :canonical_pending_transactions, :raw_pending_outgoing_check_transaction, null: false, index: {name: :index_canonical_pending_txs_on_raw_pending_outgoing_check_tx_id, algorithm: :concurrently}
  end
end
