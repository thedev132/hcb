# frozen_string_literal: true

class AddAchPaymentToCanonicalPendingTransactions < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :canonical_pending_transactions, :ach_payment, null: true, index: { algorithm: :concurrently }
  end

end
