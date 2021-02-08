class AddPendingTransactionEngineAtToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :pending_transaction_engine_at, :datetime
  end
end
