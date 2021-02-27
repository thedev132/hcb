class Fee < ApplicationRecord
  belongs_to :canonical_event_mapping

  validates :reason, presence: true
  validates :amount_cents_as_decimal, numericality: { greater_than_or_equal_to: 0 }
  validates :event_sponsorship_fee, numericality: { greater_than_or_equal_to: 0 }

  scope :hack_club_fee, -> { where(reason: "HACK CLUB FEE") }
  scope :greater_than_0, -> { where("amount_cents_as_decimal > 0") }

  def hack_club_fee?
    reason == "HACK CLUB FEE"
  end

  def amount_decimal
    amount_cents_as_decimal / 100.0
  end

  def date
    canonical_transaction.date
  end

  def memo
    canonical_transaction.memo
  end

  def smart_memo
    canonical_transaction.smart_memo
  end

  def amount
    canonical_transaction.amount
  end

  def amount_cents
    canonical_transaction.amount_cents
  end

  private

  def canonical_transaction
    @canonical_transaction ||= canonical_event_mapping.canonical_transaction
  end
end
