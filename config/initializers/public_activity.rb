# frozen_string_literal: true

class PublicActivity::Activity
  scope :for_user, ->(user) {
    where(recipient_type: "User", recipient_id: user.id)
      .or(where(event_id: user.events.pluck(:id)))
      .or(where(recipient_type: "Event", recipient_id: user.events.pluck(:id)))
  }

  validate do
    unless owner.nil? || owner_type == User.name
      Airbrake.notify("Public Activity Validation Failed") # this is temporary so we can catch issues before releasing the feature fully.
    end

    true
  end

  def trackable_is_deletable?
    trackable_type.constantize.in?([Reimbursement::Report])
  end

end
