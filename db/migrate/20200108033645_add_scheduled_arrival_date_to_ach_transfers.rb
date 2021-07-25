# frozen_string_literal: true

class AddScheduledArrivalDateToAchTransfers < ActiveRecord::Migration[5.2]
  def change
    add_column :ach_transfers, :scheduled_arrival_date, :datetime
  end
end
