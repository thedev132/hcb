# frozen_string_literal: true

class ChangeGSuiteAasmStateToDefaultToCreating < ActiveRecord::Migration[6.0]
  def up
    change_column :g_suites, :aasm_state, :string, default: "creating"

    GSuite.configuring.find_each do |g_suite|
      g_suite.update_column(:aasm_state, "creating")
    end
  end

  def down
    GSuite.creating.find_each do |g_suite|
      g_suite.update_column(:aasm_state, "configuring")
    end

    change_column :g_suites, :aasm_state, :string, default: "configuring"
  end
end
