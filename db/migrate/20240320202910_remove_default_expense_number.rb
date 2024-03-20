class RemoveDefaultExpenseNumber < ActiveRecord::Migration[7.0]
  def change
    change_column_default :reimbursement_expenses, :expense_number, nil
  end
end
