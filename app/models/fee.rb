class Fee < ApplicationRecord
  belongs_to :canonical_event_mapping

  validates :reason, presence: true
  validates :amount_cents_as_decimal, numericality: { greater_than_or_equal_to: 0 }
  validates :event_sponsorship_fee, numericality: { greater_than_or_equal_to: 0 }

  scope :hack_club_fee, -> { where(reason: "HACK CLUB FEE") }
end
