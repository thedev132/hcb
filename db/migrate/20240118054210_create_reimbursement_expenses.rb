class CreateReimbursementExpenses < ActiveRecord::Migration[7.0]
  def change
    create_table :reimbursement_expenses do |t|
      t.belongs_to :reimbursement_report, null: false, foreign_key: true
      t.references :approved_by, foreign_key: { to_table: :users }
      t.text :memo
      t.integer :amount_cents, null: false, default: 0
      t.text :description

      t.string :aasm_state

      t.datetime :approved_at

      t.timestamps
    end
  end
end
