# frozen_string_literal: true

class AddIncreaseStatusToIncreaseCheck < ActiveRecord::Migration[7.0]
  def change
    add_column :increase_checks, :increase_status, :string
  end

end
