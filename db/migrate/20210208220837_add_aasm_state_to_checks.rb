# frozen_string_literal: true

class AddAasmStateToChecks < ActiveRecord::Migration[6.0]
  def change
    add_column :checks, :aasm_state, :string
  end
end
