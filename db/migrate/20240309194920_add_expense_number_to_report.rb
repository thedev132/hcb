class AddExpenseNumberToReport < ActiveRecord::Migration[7.0]
  def change
    add_column :reimbursement_reports, :expense_number, :integer, default: 0, null: false
  end
end
