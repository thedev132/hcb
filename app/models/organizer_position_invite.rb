# frozen_string_literal: true

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
  include FriendlyId

  friendly_id :slug_candidates, use: :slugged

  scope :pending, -> { where(accepted_at: nil, rejected_at: nil, cancelled_at: nil) }
  # tmb@hackclub: this is the scope that the SessionHelper looks to assign un-assigned invites. we need to include cancelled invites so that we can assign users to them
  scope :pending_assign, -> { where(accepted_at: nil, rejected_at: nil) }

  belongs_to :event
  belongs_to :user, required: false
  belongs_to :sender, class_name: "User"

  belongs_to :organizer_position, required: false

  validates_email_format_of :email

  validate :not_already_organizer
  validate :not_already_invited, on: :create
  validates :accepted_at, absence: true, if: -> { rejected_at.present? }
  validates :rejected_at, absence: true, if: -> { accepted_at.present? }

  after_create :send_email
  before_save :normalize_email

  def normalize_email
    # canonicalize emails as soon as possible -- otherwise, Bank gets
    # confused about who's invited and who's not when they log in.
    self.email = self.email.downcase
  end

  def send_email
    OrganizerPositionInvitesMailer.with(invite: self).notify.deliver_later
  end

  def accept
    unless user.present?
      self.errors.add(:user, "must be present to accept invite")
      return false
    end

    if cancelled?
      self.errors.add(:base, "was canceled!")
      return false
    end

    if accepted?
      self.errors.add(:base, "already accepted!")
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
    accepted_at.present?
  end

  def reject
    unless user.present?
      self.errors.add(:user, "must be present to reject invite")
      return false
    end

    if cancelled?
      self.errors.add(:base, "was canceled!")
      return false
    end

    if rejected?
      self.errors.add(:base, "already rejected!")
      return false
    end

    self.rejected_at = Time.current

    self.save
  end

  def rejected?
    rejected_at.present?
  end

  def cancel
    if accepted?
      self.errors.add(:user, "has already accepted this invite!")
      return false
    end

    if rejected?
      self.errors.add(:user, "has already rejected this invite!")
      return false
    end

    self.cancelled_at = Time.current

    self.save
  end

  def cancelled?
    cancelled_at.present?
  end

  def slug_candidates
    slug = normalize_friendly_id("#{event.try(:name)} #{email}")
    # https://github.com/norman/friendly_id/issues/480
    sequence = OrganizerPositionInvite.where("slug LIKE ?", "#{slug}-%").size + 2
    [slug, "#{slug} #{sequence}"]
  end

  private

  def not_already_organizer
    if event && event.users.pluck(:email).include?(email)
      self.errors.add(:user, "is already an organizer of this event!")
    end
  end

  def not_already_invited
    if event && event.organizer_position_invites.pending.pluck(:email).include?(email)
      self.errors.add(:user, "already has a pending invite!")
    end
  end
end
