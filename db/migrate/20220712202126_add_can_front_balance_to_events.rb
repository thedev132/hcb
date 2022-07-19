# frozen_string_literal: true

class AddCanFrontBalanceToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :can_front_balance, :boolean, default: false, null: false
  end

end
