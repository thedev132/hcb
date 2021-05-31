class AddDateToHashedTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :hashed_transactions, :date, :date
  end
end
