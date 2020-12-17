class CanonicalPendingTransaction < ApplicationRecord
  belongs_to :raw_pending_stripe_transaction, optional: true
  has_one :canonical_pending_event_mapping
  has_one :event, through: :canonical_pending_event_mapping
  has_many :canonical_pending_settled_mappings
  has_many :canonical_transactions, through: :canonical_pending_settled_mappings
  has_many :canonical_pending_declined_mappings

  monetize :amount_cents

  scope :stripe, -> { where('raw_pending_stripe_transaction_id is not null')}
  scope :unmapped, -> { includes(:canonical_pending_event_mapping).where(canonical_pending_event_mappings: {canonical_pending_transaction_id: nil}) }
  scope :unsettled, -> { 
    includes(:canonical_pending_settled_mappings).where(canonical_pending_settled_mappings: {canonical_pending_transaction_id: nil})
      .includes(:canonical_pending_declined_mappings).where(canonical_pending_declined_mappings: { canonical_pending_transaction_id: nil })
  }

  # DEPRECATED
  def display_name
    memo
  end

  def filter_data
    {} # TODO
  end

  def comments
    [] # TODO
  end
end
