# frozen_string_literal: true

class AddColumnFieldsToIncreaseCheck < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :increase_checks, :column_id, :string
    add_column :increase_checks, :column_status, :string
    add_column :increase_checks, :column_object, :jsonb

    add_index :increase_checks, :column_id, unique: true, algorithm: :concurrently
  end

end
