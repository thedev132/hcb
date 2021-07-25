# frozen_string_literal: true

class AddCreatorToGSuiteAccounts < ActiveRecord::Migration[5.2]
  def change
    add_reference :g_suite_accounts, :creator, index: true, foreign_key: {to_table: :users}
    add_column :g_suite_accounts, :backup_email, :text
  end
end
