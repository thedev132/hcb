# frozen_string_literal: true

class AddAasmStateToDisbursements < ActiveRecord::Migration[6.1]
  def change
    add_column :disbursements, :aasm_state, :string
  end

end
