# frozen_string_literal: true

class AddRawPendingDisbursementTransactionIdToCanonicalPendingTransactions < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :canonical_pending_transactions,
                  :raw_pending_incoming_disbursement_transaction,
                  null: true,
                  index: {
                    name: :index_cpts_on_raw_pending_incoming_disbursement_transaction_id,
                    algorithm: :concurrently
                  }

    add_reference :canonical_pending_transactions,
                  :raw_pending_outgoing_disbursement_transaction,
                  null: true,
                  index: {
                    name: :index_cpts_on_raw_pending_outgoing_disbursement_transaction_id,
                    algorithm: :concurrently
                  }
  end

end
