class AddFriendlyMemoToCanonicalTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :canonical_transactions, :friendly_memo, :text
  end
end
