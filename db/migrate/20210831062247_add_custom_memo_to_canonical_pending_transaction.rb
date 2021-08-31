class AddCustomMemoToCanonicalPendingTransaction < ActiveRecord::Migration[6.0]
  def change
    add_column :canonical_pending_transactions, :custom_memo, :text
  end
end
