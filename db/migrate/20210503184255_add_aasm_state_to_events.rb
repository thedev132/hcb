# frozen_string_literal: true

class AddAasmStateToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :aasm_state, :string
  end
end
