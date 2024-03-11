class CreateReimbursementReports < ActiveRecord::Migration[7.0]
  def change
    create_table :reimbursement_reports do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :event, null: false, foreign_key: true

      t.references :invited_by, foreign_key: { to_table: :users }
      t.text :invite_message

      t.text :name
      t.integer :maximum_amount_cents

      t.string :aasm_state

      t.datetime :submitted_at
      t.datetime :reimbursement_requested_at
      t.datetime :reimbursement_approved_at
      t.datetime :rejected_at
      t.datetime :reimbursed_at

      t.timestamps
    end
  end
end
