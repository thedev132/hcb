# frozen_string_literal: true

class CanonicalEventMapping < ApplicationRecord
  belongs_to :canonical_transaction
  belongs_to :event
  belongs_to :user, optional: true

  has_many :fees

  scope :missing_fee, -> { includes(:fees).where(fees: { canonical_event_mapping_id: nil }) }
  scope :mapped_by_human, -> { where("user_id is not null") }
end
