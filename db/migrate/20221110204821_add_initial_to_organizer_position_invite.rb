# frozen_string_literal: true

class AddInitialToOrganizerPositionInvite < ActiveRecord::Migration[6.1]
  def change
    add_column :organizer_position_invites, :initial, :boolean, default: false
  end

end
