class RawStripeTransaction < ApplicationRecord
  has_many :hashed_transactions

  def memo
    @memo ||= stripe_transaction.dig('merchant_data', 'name')
  end
end
