module StripeCardService
  class SetSpending
    def initialize(card_id:, amount:, interval:)
      @card_id = card_id
      @spending_limit = {
        amount: amount,
        interval: interval,
      }
    end

    def run
      StripeService::Card.update(
        @card_id,
        spending_controls: { spending_limits: [@spending_limit] }
      )
    end
  end
end