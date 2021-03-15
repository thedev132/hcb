class AddAasmStateToDonations < ActiveRecord::Migration[6.0]
  def change
    add_column :donations, :aasm_state, :string
  end
end
