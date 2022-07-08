# frozen_string_literal: true

class DropEmailFromOrganizerPositionInvites < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :organizer_position_invites, :email
    end
  end

end
