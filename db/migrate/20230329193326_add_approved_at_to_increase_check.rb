# frozen_string_literal: true

class AddApprovedAtToIncreaseCheck < ActiveRecord::Migration[7.0]
  def change
    add_column :increase_checks, :approved_at, :datetime
  end

end
