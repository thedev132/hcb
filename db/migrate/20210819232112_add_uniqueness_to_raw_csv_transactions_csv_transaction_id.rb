class AddUniquenessToRawCsvTransactionsCsvTransactionId < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :raw_csv_transactions, :csv_transaction_id, unique: true, algorithm: :concurrently
  end
end
