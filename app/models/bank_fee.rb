class BankFee < ApplicationRecord
  include AASM

  belongs_to :event

  monetize :amount_cents

  before_create :set_hcb_code

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

  def set_hcb_code
    self.hcb_code = "HCB-#{::TransactionGroupingEngine::Calculate::HcbCode::BANK_FEE_CODE}-#{id}"
  end
end
