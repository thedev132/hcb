# frozen_string_literal: true

class AddDeletedAtToOrganizerPositions < ActiveRecord::Migration[5.2]
  def change
    add_column :organizer_positions, :deleted_at, :datetime
  end
end
