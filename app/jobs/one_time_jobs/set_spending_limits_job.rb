# frozen_string_literal: true

module OneTimeJobs
  class SetSpendingLimitsJob < ApplicationJob
    def perform(card)
      if card
        set_spending_limit card
      else
        StripeCard.all.map(&:set_spending_limit)
      end
    end

    private

    def set_spending_limit(card)
      ::StripeCardService::SetSpending.new(card_id: card.stripe_id,
                                           interval: "daily",
                                           amount: 500 * 100
                                          ).run
    end
  end
end
