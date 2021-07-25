# frozen_string_literal: true

class AddDuplicateTransactionRefToHashedTransactions < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_reference :hashed_transactions, :duplicate_of_hashed_transaction, index: {algorithm: :concurrently}
  end
end
