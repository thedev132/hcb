# frozen_string_literal: true

class AddCheckNumberToIncreaseChecks < ActiveRecord::Migration[7.0]
  def change
    add_column :increase_checks, :check_number, :string
  end

end
