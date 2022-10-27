# frozen_string_literal: true

class AddFirstTimeToOrganizerPositions < ActiveRecord::Migration[6.1]
  def change
    add_column :organizer_positions, :first_time, :boolean, default: false
    change_column_default :organizer_positions, :first_time, true
  end

end
