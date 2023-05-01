# frozen_string_literal: true

class AddTransactionSourceToCanonicalTransactions < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :canonical_transactions, :transaction_source, polymorphic: true, null: true, index: { algorithm: :concurrently }
  end

end
