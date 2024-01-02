# frozen_string_literal: true

class AddColumnIdToAchTransfers < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :ach_transfers, :column_id, :text
    add_index :ach_transfers, :column_id, unique: true, algorithm: :concurrently
  end

end
