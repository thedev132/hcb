class AddUniqueBankIdentifierToHashedTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :hashed_transactions, :unique_bank_identifier, :text
  end
end
