class MfaRequest < ApplicationRecord
  include AASM

  belongs_to :mfa_code, optional: true
  scope :svb, -> { where(provider: 'SVB') }

  aasm do
    state :pending, initial: true
    state :received

    event :mark_received do
      transitions from: :pending, to: :received
    end
  end

end
