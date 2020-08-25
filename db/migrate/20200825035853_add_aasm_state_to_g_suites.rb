class AddAasmStateToGSuites < ActiveRecord::Migration[6.0]
  def change
    add_column :g_suites, :aasm_state, :string
  end
end
