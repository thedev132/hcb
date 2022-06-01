# frozen_string_literal: true

class ChangeEventOnOrganizerPositionInviteToNotNull < ActiveRecord::Migration[6.1]
  class OrganizerPositionInvite < ActiveRecord::Base
  end

  def change
    OrganizerPositionInvite.where(event_id: nil).each do |opi|
      opi.destroy!
    end

    safety_assured do
      change_column_null :organizer_position_invites, :event_id, false
    end
  end

end
