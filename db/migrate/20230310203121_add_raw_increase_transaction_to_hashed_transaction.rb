# frozen_string_literal: true

class AddRawIncreaseTransactionToHashedTransaction < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :hashed_transactions, :raw_increase_transaction, null: true, index: { algorithm: :concurrently }
  end

end
