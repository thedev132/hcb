# frozen_string_literal: true

class AddShouldSyncToBankAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :bank_accounts, :should_sync, :boolean, default: true
  end
end
