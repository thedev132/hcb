class CreateReimbursementPayoutHoldings < ActiveRecord::Migration[7.0]
  def change
    create_table :reimbursement_payout_holdings do |t|
      t.integer :amount_cents, null: false
      t.string :hcb_code
      t.references :reimbursement_reports, null: false
      t.references :increase_checks, null: true
      t.references :ach_transfers, null: true
      t.string :aasm_state

      t.timestamps
    end
  end
end
