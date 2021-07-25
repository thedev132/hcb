# frozen_string_literal: true

class AddInitialPasswordToGSuiteAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :g_suite_accounts, :initial_password, :string
  end
end
