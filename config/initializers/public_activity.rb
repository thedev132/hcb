# frozen_string_literal: true

class PublicActivity::Activity
  scope :for_user, ->(user) {
    where(recipient_type: "User", recipient_id: user.id)
      .or(where(event_id: user.events.pluck(:id)))
      .or(where(recipient_type: "Event", recipient_id: user.events.pluck(:id)))
  }

  validate do
    owner.nil? || owner_type == User.name
  end

  def trackable_is_deletable?
    trackable_type.constantize.in?([Reimbursement::Report, WebauthnCredential])
  end

end
