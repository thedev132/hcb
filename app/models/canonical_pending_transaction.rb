class CanonicalPendingTransaction < ApplicationRecord
  belongs_to :raw_pending_stripe_transaction, optional: true
  has_one :canonical_pending_event_mapping
  has_one :event, through: :canonical_pending_event_mapping

  monetize :amount_cents

  scope :stripe, -> { where('raw_pending_stripe_transaction_id is not null')}
  scope :unmapped, -> { includes(:canonical_pending_event_mapping).where(canonical_pending_event_mappings: {canonical_pending_transaction_id: nil}) }
end
