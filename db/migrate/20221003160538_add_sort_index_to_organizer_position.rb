# frozen_string_literal: true

class AddSortIndexToOrganizerPosition < ActiveRecord::Migration[6.1]
  def change
    add_column :organizer_positions, :sort_index, :float
  end

end
