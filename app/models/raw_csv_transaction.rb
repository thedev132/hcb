# frozen_string_literal: true

class RawCsvTransaction < ApplicationRecord
  has_many :hashed_transactions

  scope :unhashed, -> { left_joins(:hashed_transactions).where(hashed_transactions: {raw_csv_transaction_id: nil}) }

  monetize :amount_cents
end
