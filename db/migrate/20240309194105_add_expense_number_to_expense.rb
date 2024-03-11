class AddExpenseNumberToExpense < ActiveRecord::Migration[7.0]
  def change
    add_column :reimbursement_expenses, :expense_number, :integer, default: 0, null: false
  end
end
