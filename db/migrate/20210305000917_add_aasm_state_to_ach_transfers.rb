# frozen_string_literal: true

class AddAasmStateToAchTransfers < ActiveRecord::Migration[6.0]
  def change
    add_column :ach_transfers, :aasm_state, :string
  end
end
