# frozen_string_literal: true

class ChangeDefaultForCanFrontBalance < ActiveRecord::Migration[7.0]
  def change
    change_column_default :events, :can_front_balance, true
  end

end
