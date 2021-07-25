# frozen_string_literal: true

class AddRawPendingOutgoingAchTransactionIdToCanonicalPendingTransactions < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    change_column_null :canonical_pending_transactions, :raw_pending_outgoing_check_transaction_id, true
    add_reference :canonical_pending_transactions, :raw_pending_outgoing_ach_transaction, null: true, index: {name: :index_canonical_pending_txs_on_raw_pending_outgoing_ach_tx_id, algorithm: :concurrently}
  end
end
