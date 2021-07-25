# frozen_string_literal: true

class CreateGSuiteAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :g_suite_accounts do |t|
      t.text :address
      t.timestamp :accepted_at
      t.timestamp :rejected_at
      t.references :g_suite, foreign_key: true

      t.timestamps
    end
  end
end
