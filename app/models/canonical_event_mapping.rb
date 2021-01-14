class CanonicalEventMapping < ApplicationRecord
  belongs_to :canonical_transaction
  belongs_to :event

  has_many :fees

  scope :missing_fee, -> { includes(:fees).where(fees: { canonical_event_mapping_id: nil }) }
end
