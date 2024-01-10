# frozen_string_literal: true

class CreateAdminLedgerAudits < ActiveRecord::Migration[7.0]
  def change
    create_table :admin_ledger_audits do |t|
      t.date :start

      t.timestamps
    end
  end

end
