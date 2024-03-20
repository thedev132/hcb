class AddDeletedAtToExpenses < ActiveRecord::Migration[7.0]
  def change
    add_column :reimbursement_expenses, :deleted_at, :timestamp
  end
end
