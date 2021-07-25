# frozen_string_literal: true

class BankFee < ApplicationRecord
  include AASM

  belongs_to :event

  monetize :amount_cents

  after_create :set_hcb_code

  scope :since_feature_launch, -> { where("created_at > ?", Time.utc(2021, 05, 20)) }
  scope :in_transit_or_pending, -> { where("aasm_state in (?)", ["pending", "in_transit"]) }

  aasm do
    state :pending, initial: true
    state :in_transit
    state :settled

    event :mark_in_transit do
      transitions from: :pending, to: :in_transit
    end

    event :mark_settled do
      transitions from: :in_transit, to: :settled
    end
  end

  def state
    return :success if settled?
    return :info if in_transit?

    :muted
  end

  def state_text
    return "Settled" if settled?
    return "Paid & Settling" if in_transit?

    "Pending"
  end

  def local_hcb_code
    @local_hcb_code ||= HcbCode.find_or_create_by(hcb_code: hcb_code)
  end

  def canonical_pending_transaction
    canonical_pending_transactions.first
  end

  def canonical_transactions
    @canonical_transactions ||= CanonicalTransaction.where(hcb_code: hcb_code)
  end

  def canonical_pending_transactions
    @canonical_pending_transactions ||= begin
      return [] unless raw_pending_bank_fee_transaction.present?

      ::CanonicalPendingTransaction.where(raw_pending_bank_fee_transaction_id: raw_pending_bank_fee_transaction.id)
    end
  end

  private

  def set_hcb_code
    self.update_column(:hcb_code, "HCB-#{::TransactionGroupingEngine::Calculate::HcbCode::BANK_FEE_CODE}-#{id}")
  end

  def raw_pending_bank_fee_transaction
    raw_pending_bank_fee_transactions.first
  end

  def raw_pending_bank_fee_transactions
    @raw_pending_bank_fee_transactions ||= ::RawPendingBankFeeTransaction.where(bank_fee_transaction_id: id)
  end

end
