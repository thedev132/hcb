class AddRoleToOrganizerPositionInvite < ActiveRecord::Migration[7.0]
  def change
    add_column :organizer_position_invites, :role, :integer, null: false, default: 100
  end
end
