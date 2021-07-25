# frozen_string_literal: true

class AddUniqueBankIdentifierToRawPlaidTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :raw_plaid_transactions, :unique_bank_identifier, :string, null: false
  end
end
