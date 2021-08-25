# frozen_string_literal: true

class TransactionCsv < ApplicationRecord
  include AASM

  has_one_attached :file

  validates :file, attached: true

  aasm do
    state :pending, initial: true
    state :processing
    state :processed

    event :mark_processing do
      transitions from: :pending, to: :processing
    end

    event :mark_processed do
      transitions from: :processing, to: :processed
    end
  end
end
