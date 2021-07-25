# frozen_string_literal: true

class AddUniqueBankIdentifierToRawEmburseTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :raw_emburse_transactions, :unique_bank_identifier, :string, null: false
  end
end
