# frozen_string_literal: true

class CreateJoinTableHcbCodesComplianceChecks < ActiveRecord::Migration[7.0]
  def change
    create_table :admin_ledger_audit_tasks do |t|
      t.references :hcb_code, foreign_key: true
      t.references :admin_ledger_audit, foreign_key: true
      t.references :reviewer, foreign_key: { to_table: :users }
      t.string :status, default: "pending"
      t.timestamps
    end
  end
end