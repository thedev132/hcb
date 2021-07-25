# frozen_string_literal: true

class AddPositionToOrganizerPositionInvites < ActiveRecord::Migration[5.2]
  def change
    add_reference :organizer_position_invites, :organizer_position, foreign_key: true
  end
end
