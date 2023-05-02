# frozen_string_literal: true

class AddCheckDepositToCanonicalPendingTransactions < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :canonical_pending_transactions, :check_deposit, null: true, index: { algorithm: :concurrently }
  end

end
