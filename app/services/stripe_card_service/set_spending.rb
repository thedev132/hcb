# frozen_string_literal: true

module StripeCardService
  class SetSpending
    def initialize(card_id:, amount:, interval:)
      @card_id = card_id
      @card = Card.find_by(stripe_id: card_id)
      @spending_limit = {
        amount: amount,
        interval: interval,
      }
    end

    def run
      StripeService::Issuing::Card.update(
        @card_id,
        spending_controls: { spending_limits: [@spending_limit] }
      )
      @card.sync_from_stripe!
    end
  end
end
