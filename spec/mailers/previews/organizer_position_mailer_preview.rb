# frozen_string_literal: true

class OrganizerPositionMailerPreview < ActionMailer::Preview
  def role_change
    organizer_position = OrganizerPosition.last
    previous_role = OrganizerPosition.roles.keys.excluding(organizer_position.role).last
    changer = User.last

    OrganizerPositionMailer.with(organizer_position:, previous_role:, changer:).role_change
  end

end
