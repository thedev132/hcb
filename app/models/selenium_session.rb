# frozen_string_literal: true

class SeleniumSession < ApplicationRecord
  include AASM

  aasm do
    state :active, initial: true
    state :expired

    event :mark_expired do
      transitions from: :active, to: :expired
    end
  end
end
