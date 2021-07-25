# frozen_string_literal: true

class RemoveUselessIndex < ActiveRecord::Migration[5.2]
  def change
    remove_index :organizer_position_invites, name: "index_organizer_position_invites_uniqueness"
  end
end
