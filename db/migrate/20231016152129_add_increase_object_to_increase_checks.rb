# frozen_string_literal: true

class AddIncreaseObjectToIncreaseChecks < ActiveRecord::Migration[7.0]
  def change
    add_column :increase_checks, :increase_object, :jsonb
  end

end
