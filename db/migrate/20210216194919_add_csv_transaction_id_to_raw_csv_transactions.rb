# frozen_string_literal: true

class AddCsvTransactionIdToRawCsvTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :raw_csv_transactions, :csv_transaction_id, :text
  end
end
