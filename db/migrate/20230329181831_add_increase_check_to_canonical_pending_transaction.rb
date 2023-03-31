# frozen_string_literal: true

class AddIncreaseCheckToCanonicalPendingTransaction < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :canonical_pending_transactions, :increase_check, null: true, index: { algorithm: :concurrently }
  end

end
