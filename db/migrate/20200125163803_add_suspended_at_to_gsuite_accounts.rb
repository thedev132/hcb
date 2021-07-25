# frozen_string_literal: true

class AddSuspendedAtToGsuiteAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :g_suite_accounts, :suspended_at, :datetime
  end
end
