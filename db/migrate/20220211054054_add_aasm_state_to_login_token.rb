# frozen_string_literal: true

class AddAasmStateToLoginToken < ActiveRecord::Migration[6.0]
  def change
    add_column :login_tokens, :aasm_state, :string
  end

end
