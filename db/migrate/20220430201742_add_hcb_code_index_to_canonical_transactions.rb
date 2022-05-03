# frozen_string_literal: true

class AddHcbCodeIndexToCanonicalTransactions < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :canonical_transactions, :hcb_code, algorithm: :concurrently
  end

end
