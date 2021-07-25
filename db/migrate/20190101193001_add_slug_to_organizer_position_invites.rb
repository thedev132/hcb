# frozen_string_literal: true

class AddSlugToOrganizerPositionInvites < ActiveRecord::Migration[5.2]
  def change
    add_column :organizer_position_invites, :slug, :string
    add_index :organizer_position_invites, :slug, unique: true
  end
end
