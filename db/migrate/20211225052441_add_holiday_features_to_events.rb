# frozen_string_literal: true

class AddHolidayFeaturesToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :holiday_features, :boolean, null: false, default: true
  end

end
