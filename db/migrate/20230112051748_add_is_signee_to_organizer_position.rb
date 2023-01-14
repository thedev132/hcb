# frozen_string_literal: true

class AddIsSigneeToOrganizerPosition < ActiveRecord::Migration[6.1]
  def change
    add_column :organizer_positions, :is_signee, :boolean
  end

end
