# frozen_string_literal: true

class OrganizerPosition < ApplicationRecord
  acts_as_paranoid

  belongs_to :user
  belongs_to :event

  has_one :organizer_position_invite
  has_many :organizer_position_deletion_requests

  validates :user, uniqueness: { scope: :event, conditions: -> { where(deleted_at: nil) } }
end
