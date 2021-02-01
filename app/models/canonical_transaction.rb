class CanonicalTransaction < ApplicationRecord
  include Receiptable

  scope :unmapped, -> { includes(:canonical_event_mapping).where(canonical_event_mappings: {canonical_transaction_id: nil}) }

  scope :revenue, -> { where("amount_cents > 0") }
  scope :expense, -> { where("amount_cents < 0") }

  scope :likely_github, -> { where("memo ilike '%github grant%'") }
  scope :likely_hack_club_fee, -> { where("memo ilike '%Hack Club Bank Fee TO ACCOUNT%'") }

  monetize :amount_cents

  has_many :canonical_hashed_mappings
  has_many :hashed_transactions, through: :canonical_hashed_mappings
  has_one :canonical_event_mapping
  has_one :event, through: :canonical_event_mapping
  has_one :canonical_pending_settled_mapping
  has_one :canonical_pending_transaction, through: :canonical_pending_settled_mapping
  has_many :fees, through: :canonical_event_mapping

  def smart_memo
    @smart_memo ||= ::TransactionEngine::SyntaxSugarService::Memo.new(canonical_transaction: self).run
  end

  def likely_hack_club_fee?
    memo.to_s.upcase.include?("HACK CLUB BANK FEE TO ACCOUNT")
  end

  def linked_object
    @linked_object ||= TransactionEngine::SyntaxSugarService::LinkedObject.new(canonical_transaction: self).run
  end

  # DEPRECATED
  def marked_no_or_lost_receipt_at=(v)
    v
  end

  def marked_no_or_lost_receipt_at
    nil
  end

  def display_name # in deprecated system this is the renamed transaction name
    smart_memo
  end

  def name # in deprecated system this is the imported name
   smart_memo
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
    return linked_object if linked_object.is_a?(Check)

    nil # TODO
  end

  def donation_payout
    nil # TODO
  end

  def fee_applies?
    @fee_applies ||= fees.greater_than_0.exists?
  end

  def emburse_transfer
    nil # TODO
  end

  def disbursement
    nil # TODO
  end
end
