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

  def name # in deprecated system this is the imported name
    memo
  end

  def filter_data
    {} # TODO
  end

  def comments
    [] # TODO
  end

  def fee_payment?
    false # TODO
  end

  def invoice_payout
    nil # TODO
  end

  def fee_reimbursement
    nil # TODO
  end

  def check
    nil # TODO
  end

  def donation_payout
    nil # TODO
  end

  def fee_applies?
    nil # TODO
  end

  def emburse_transfer
    nil # TODO
  end

  def disbursement
    nil # TODO
  end
end
