# frozen_string_literal: true

class AddHcbCodeIndexToCanonicalPendingTransactions < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :canonical_pending_transactions, :hcb_code, algorithm: :concurrently
  end

end
