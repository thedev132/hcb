# frozen_string_literal: true

class AddIncreaseStatusToCheckDeposits < ActiveRecord::Migration[7.0]
  def change
    add_column :check_deposits, :increase_status, :string
  end

end
