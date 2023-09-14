# frozen_string_literal: true

class ChangeIncreaseCheckUserIdNull < ActiveRecord::Migration[7.0]
  def change
    change_column_null :increase_checks, :user_id, true
  end

end
