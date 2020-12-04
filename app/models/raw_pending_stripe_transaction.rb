class RawPendingStripeTransaction < ApplicationRecord
  monetize :amount_cents

  def date
    date_posted
  end

  def memo
    stripe_transaction.dig('merchant_data', 'name')
  end
end
