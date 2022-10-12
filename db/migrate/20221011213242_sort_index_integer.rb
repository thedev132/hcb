# frozen_string_literal: true

class SortIndexInteger < ActiveRecord::Migration[6.1]
  def change
    safety_assured { change_column :organizer_positions, :sort_index, :integer }
  end

end
