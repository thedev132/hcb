# frozen_string_literal: true

class AddScheduledOnToAchTransfers < ActiveRecord::Migration[7.0]
  def change
    add_column :ach_transfers, :scheduled_on, :date
  end

end
