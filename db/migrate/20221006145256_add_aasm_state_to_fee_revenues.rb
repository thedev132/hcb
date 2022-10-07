# frozen_string_literal: true

class AddAasmStateToFeeRevenues < ActiveRecord::Migration[6.1]
  def change
    add_column :fee_revenues, :aasm_state, :string
  end

end
