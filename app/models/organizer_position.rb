class OrganizerPosition < ApplicationRecord
  belongs_to :user
  belongs_to :event

  has_one :organizer_position_invite
end
