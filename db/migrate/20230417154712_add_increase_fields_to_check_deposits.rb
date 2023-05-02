# frozen_string_literal: true

class AddIncreaseFieldsToCheckDeposits < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :check_deposits, :front_file_id, :string
    add_column :check_deposits, :back_file_id, :string
    add_column :check_deposits, :increase_id, :string

    add_index :check_deposits, :increase_id, unique: true, algorithm: :concurrently
  end

end
