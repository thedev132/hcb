class ChangeColumnTypeForRawEmburseTransactionId < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    safety_assured do
      change_column :hashed_transactions, :raw_emburse_transaction_id, :bigint
    end
  end
end
