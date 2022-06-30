# frozen_string_literal: true

class ChangeUserOnOrganizerPositionInviteToNotNull < ActiveRecord::Migration[6.1]
  class OrganizerPositionInvite < ActiveRecord::Base
  end

  def change
    safety_assured do
      change_column_null :organizer_position_invites, :user_id, false
    end
  end

end
