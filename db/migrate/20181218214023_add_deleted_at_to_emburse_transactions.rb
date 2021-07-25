# frozen_string_literal: true

class AddDeletedAtToEmburseTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :emburse_transactions, :deleted_at, :datetime
    add_index :emburse_transactions, :deleted_at
  end
end
