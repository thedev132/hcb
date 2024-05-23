# frozen_string_literal: true

class PublicActivity::Activity
  scope :for_user, ->(user) {
    where("recipient_type = 'User' AND recipient_id = ?", user.id).or(where(event_id: user.events.pluck(:id)))
  }

end
