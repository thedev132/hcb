class RawPendingStripeTransaction < ApplicationRecord
  monetize :amount_cents

  def date
    date_posted
  end

  def memo
    stripe_transaction.dig('merchant_data', 'name')
  end

  def likely_event_id
    @likely_event_id ||= ::StripeCard.find_by!(stripe_id: stripe_card_id).event_id
  end

  private

  def stripe_card_id
    stripe_transaction.dig('card', 'id')
  end
end
