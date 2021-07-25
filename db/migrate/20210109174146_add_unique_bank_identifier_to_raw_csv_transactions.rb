# frozen_string_literal: true

class AddUniqueBankIdentifierToRawCsvTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :raw_csv_transactions, :unique_bank_identifier, :string, null: false
  end
end
