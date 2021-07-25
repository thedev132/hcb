# frozen_string_literal: true

class PayForIssuedCardJob < ApplicationJob
  queue_as :default

  def perform(card)
    return if card.purchased_at.present?

    puts "Paying Stripe for issued card ##{card.id}"

    StripeService::Topup.create({
      amount: card.issuing_cost,
      currency: "usd",
      statement_descriptor: "Issued card #{card.id}"
      # (@msw) destination_balance is empty, because issuing a new stripe card
      # charges the main balance
    })
    card.update(purchased_at: Time.now)
    card.save
    puts "Just paid #{card.issuing_cost} cents for card ##{card.id}"
  end
end
