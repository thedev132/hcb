# frozen_string_literal: true

class AddInTransitAtToDonations < ActiveRecord::Migration[7.0]
  def change
    add_column :donations, :in_transit_at, :datetime
  end

end
