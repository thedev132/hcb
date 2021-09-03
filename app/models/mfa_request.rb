# frozen_string_literal: true

class MfaRequest < ApplicationRecord
  include AASM

  belongs_to :mfa_code, optional: true

  aasm do
    state :pending, initial: true
    state :received

    event :mark_received do
      transitions from: :pending, to: :received
    end
  end

end
