# frozen_string_literal: true

class AddRawCsvTransactionToHashedTransactions < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_reference :hashed_transactions, :raw_csv_transaction, index: {algorithm: :concurrently}
  end
end
