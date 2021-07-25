# frozen_string_literal: true

class RawPlaidTransaction < ApplicationRecord
  has_many :hashed_transactions

  monetize :amount_cents

  def memo
    @memo ||= plaid_transaction["name"]
  end
end
