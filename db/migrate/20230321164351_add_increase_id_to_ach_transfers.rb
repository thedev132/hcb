# frozen_string_literal: true

class AddIncreaseIdToAchTransfers < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :ach_transfers, :increase_id, :text
    add_index :ach_transfers, :increase_id, unique: true, algorithm: :concurrently
  end

end
