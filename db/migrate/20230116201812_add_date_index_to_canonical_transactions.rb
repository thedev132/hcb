# frozen_string_literal: true

class AddDateIndexToCanonicalTransactions < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :canonical_transactions, :date, algorithm: :concurrently
  end

end
