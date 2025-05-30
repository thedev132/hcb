# frozen_string_literal: true

class AddRunningBalanceEnabledToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :running_balance_enabled, :boolean, null: false, default: false
  end

end
