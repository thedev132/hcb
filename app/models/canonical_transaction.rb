class CanonicalTransaction < ApplicationRecord
  scope :unmapped, -> { includes(:canonical_event_mapping).where(canonical_event_mappings: {canonical_transaction_id: nil}) }

  scope :revenue, -> { where("amount_cents > 0") }
  scope :expense, -> { where("amount_cents < 0") }

  scope :likely_github, -> { where("memo ilike '%github grant%'") }
  scope :likely_hack_club_fee, -> { where("memo ilike '%Hack Club Bank Fee%'") }

  monetize :amount_cents

  has_many :canonical_hashed_mappings
  has_many :hashed_transactions, through: :canonical_hashed_mappings
  has_one :canonical_event_mapping
  has_one :event, through: :canonical_event_mapping
  has_one :canonical_pending_settled_mapping
  has_one :canonical_pending_transaction, through: :canonical_pending_settled_mapping

  
  # DEPRECATED
  def display_name # in deprecated system this is the renamed transaction name
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
