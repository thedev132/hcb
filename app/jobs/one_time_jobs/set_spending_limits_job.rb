# frozen_string_literal: true

module OneTimeJobs
  class SetSpendingLimitsJob < ApplicationJob
    def perform(card = nil)
      if card
        set_spending_limit card
      else
        StripeCard.all.map { |card| set_spending_limit card }
      end
    end

    private

    def set_spending_limit(card)
      return if card.stripe_status == "deleted"
      ::StripeCardService::SetSpending.new(card_id: card.stripe_id,
                                           interval: "daily",
                                           amount: 20_000 * 100 # $20,000 in cents
                                          ).run
    end
  end
end
