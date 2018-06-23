# OrganizerPositionInvites are used to invite users - whether they already
# exist or not - to manage an Event.
#
# One of the oddities we need to deal with is that the User being invited will
# usually not already exist in the database. Here's how we're dealing with it.
#
# Scenario 1: User being invited does not exist in the database
#
#  1. OrganizerPositionInvite is created. Event and email are set, user is not.
#  2. Notification email is sent to invitee
#  3. Invitee goes to bank and logs in for the first time, creating a record for
#     a User with their email in the database
#  4. When the User is first created, a trigger in User is called that searches
#     for any OrganizerPositionInvites with an email match that don't yet have
#     an associated User and associates them
#
# Scenario 2: User being invited exists in the database
#
#  1. OrganizerPositionInvite is created. Event, email, and user all get set on
#     creation.
#
class OrganizerPositionInvite < ApplicationRecord
  scope :pending, -> { where(accepted_at: nil, rejected_at: nil) }

  belongs_to :event
  belongs_to :user, required: false
  belongs_to :sender, class_name: 'User'

  belongs_to :organizer_position, required: false

  validates :accepted_at, absence: true, if: -> { rejected_at.present? }
  validates :rejected_at, absence: true, if: -> { accepted_at.present? }

  after_create :send_email

  def send_email
    OrganizerPositionInvitesMailer.with(invite: self).notify.deliver_later
  end

  def accept
    unless self.user.present?
      self.errors.add(:user, 'must be present to accept invite')
      return false
    end

    if self.accepted?
      self.errors.add(:base, 'already accepted!')
      return false
    end

    self.organizer_position = OrganizerPosition.new(
      event: event,
      user: user
    )

    self.accepted_at = Time.current

    self.save
  end

  def accepted?
    self.accepted_at.present?
  end

  def reject
    unless self.user.present?
      self.errors.add(:user, 'must be present to reject invite')
      return false
    end

    if self.rejected?
      self.errors.add(:base, 'already rejected!')
      return false
    end

    self.rejected_at = Time.current

    self.save
  end

  def rejected?
    self.rejected_at.present?
  end
end
