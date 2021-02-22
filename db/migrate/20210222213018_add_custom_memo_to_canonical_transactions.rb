class AddCustomMemoToCanonicalTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :canonical_transactions, :custom_memo, :text
  end
end
