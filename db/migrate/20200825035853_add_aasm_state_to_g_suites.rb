# frozen_string_literal: true

class AddAasmStateToGSuites < ActiveRecord::Migration[6.0]
  def change
    add_column :g_suites, :aasm_state, :string, default: "configuring"
  end
end
