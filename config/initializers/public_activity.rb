# frozen_string_literal: true

class PublicActivity::Activity
  scope :for_user, ->(user) {
    where(recipient_type: "User", recipient_id: user.id)
      .or(where(event_id: user.events.pluck(:id)))
      .or(where(recipient_type: "Event", recipient_id: user.events.pluck(:id)))
  }

  include Turbo::Broadcastable

  # after_create_commit -> {
  #  streams = []

  #  if event_id
  #    Event.find(event_id).users.each do |user|
  #      streams << [user, "activities"]
  #    end
  #  end

  #  if recipient.is_a?(User)
  #    streams << [recipient, "activities"]
  #  end

  #  if recipient.is_a?(Event)
  #    recipient.users.each do |user|
  #      streams << [user, "activities"]
  #    end
  #  end

  #  User.admin.each do |user|
  #    streams << [user, "activities"]
  #  end

  #  streams.uniq.each do |stream|
  #    broadcast_action_later_to(
  #      stream,
  #      action: :prepend,
  #      target: "activities-1",
  #      partial: "public_activity/activity",
  #      locals: { activity: self, current_user: streams.first }
  #    )

  #  end
  # }

  validate do
    owner.nil? || owner_type == User.name
  end

  def trackable_is_deletable?
    trackable_type.constantize.in?([Reimbursement::Report, WebauthnCredential])
  end

end
