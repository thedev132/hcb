# frozen_string_literal: true

class Partner < ApplicationRecord
  has_paper_trail

  EXCLUDED_SLUGS = %w(connect api donations donation connects organization organizations)

  attribute :api_key, :string, default: -> { new_api_key }

  has_many :events
  has_many :partnered_signups
  has_many :partner_donations, through: :events

  validates :slug, exclusion: { in: EXCLUDED_SLUGS }, uniqueness: true
  validates :api_key, presence: true, uniqueness: true

  encrypts :stripe_api_key

  def add_user_to_partnered_event!(user_email:, event:)
    # @msw: I take full responsibility the aweful way this is being implemented.
    # To my future self, or other devs: this should be moved to a service, and
    # be given proper validations.

    user = User.find_by(email: user_email)
    unless user
      User.create!(email: user_email)
    end

    position_exists = event.users.include?(user)
    invite_exists= event.organizer_position_invites.where(email: user_email).any?

    unless position_exists or invite_exists
      partnered_email = "bank+#{event.partner.slug}@hackclub.com"
      invite_sender = User.find_by(email: partnered_email)
      invite_sender ||= User.create!(email: partnered_email)
      OrganizerPositionInvite.create!(
        event: event,
        user: user,
        sender: invite_sender
      )
    end

    partner
  end

  def regenerate_api_key!
    self.api_key = new_api_key
    self.save!
  end

  def default_org_sponsorship_fee
    0.10
  end

  private

  def new_api_key
    "hcbk_#{SecureRandom.hex(32)}"
  end

  def self.new_api_key
    self.new.send(:new_api_key)
  end
end
