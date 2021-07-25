# frozen_string_literal: true

class AddCancelledAtToOrganizerPositionInvites < ActiveRecord::Migration[5.2]
  def change
    add_column :organizer_position_invites, :cancelled_at, :datetime
  end
end
