class BankFee < ApplicationRecord
  include AASM

  belongs_to :event

  monetize :amount_cents

  aasm do
    state :pending, initial: true
    state :settled

    event :mark_settled do
      transitions from: :pending, to: :settled
    end
  end
end
