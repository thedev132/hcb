# frozen_string_literal: true

class AddTransactionMemoUniqueIndexToFeeReimbursements < ActiveRecord::Migration[5.2]
  def change
    add_index :fee_reimbursements, :transaction_memo, unique: true
  end
end
