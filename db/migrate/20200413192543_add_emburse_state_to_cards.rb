# frozen_string_literal: true

class AddEmburseStateToCards < ActiveRecord::Migration[5.2]
  def change
    add_column :cards, :emburse_state, :string
  end
end
