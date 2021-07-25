# frozen_string_literal: true

class AddAcceptRejectFieldsToOrganizerPositionInvites < ActiveRecord::Migration[5.2]
  def change
    add_column :organizer_position_invites, :accepted_at, :datetime
    add_column :organizer_position_invites, :rejected_at, :datetime
  end
end
