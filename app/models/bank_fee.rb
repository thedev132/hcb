class BankFee < ApplicationRecord
  include AASM

  belongs_to :event

  monetize :amount_cents

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
end
