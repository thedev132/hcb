# frozen_string_literal: true

class AddSameDayToAchTransfers < ActiveRecord::Migration[7.0]
  def change
    add_column :ach_transfers, :same_day, :boolean, null: false, default: false
  end

end
