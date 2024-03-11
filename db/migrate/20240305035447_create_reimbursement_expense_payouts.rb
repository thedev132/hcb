class CreateReimbursementExpensePayouts < ActiveRecord::Migration[7.0]
  def change
    create_table :reimbursement_expense_payouts do |t|
      t.references :event, null: false, foreign_key: true
      t.string :hcb_code
      t.string :aasm_state
      t.integer :amount_cents, null: false

      t.references :reimbursement_payout_holdings, null: true, index: { name: :index_expense_payouts_on_expense_payout_holdings_id }
      t.references :reimbursement_expenses, null: false, index: { name: :index_expense_payouts_on_expenses_id }

      t.timestamps
    end
  end
end
