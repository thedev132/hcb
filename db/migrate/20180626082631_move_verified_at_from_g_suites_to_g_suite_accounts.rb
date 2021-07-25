# frozen_string_literal: true

class MoveVerifiedAtFromGSuitesToGSuiteAccounts < ActiveRecord::Migration[5.2]
  def change
    remove_column :g_suites, :verified_at
    add_column :g_suite_accounts, :verified_at, :timestamp
  end
end
