class AddUniqueConstraintToHcbCodePersonalTransactions < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!
  def change
    remove_index :hcb_code_personal_transactions, :hcb_code_id
    add_index :hcb_code_personal_transactions, :hcb_code_id, unique: true, algorithm: :concurrently
  end
end
