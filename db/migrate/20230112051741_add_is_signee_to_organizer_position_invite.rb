# frozen_string_literal: true

class AddIsSigneeToOrganizerPositionInvite < ActiveRecord::Migration[6.1]
  def change
    add_column :organizer_position_invites, :is_signee, :boolean
  end

end
