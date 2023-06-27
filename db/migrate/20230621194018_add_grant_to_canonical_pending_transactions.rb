# frozen_string_literal: true

class AddGrantToCanonicalPendingTransactions < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :canonical_pending_transactions, :grant, null: true, index: { algorithm: :concurrently }
  end

end
