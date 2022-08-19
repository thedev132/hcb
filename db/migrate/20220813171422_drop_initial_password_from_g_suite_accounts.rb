# frozen_string_literal: true

class DropInitialPasswordFromGSuiteAccounts < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :g_suite_accounts, :initial_password
    end
  end

end
