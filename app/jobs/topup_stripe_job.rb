class TopupStripeJob < ApplicationJob
  queue_as :default

  def perform
    buffer = 1000 * 100 # amount of floating money that should be in stripe at any given time
    balances = StripeService::Balance.retrieve
    pending = balances[:issuing][:pending][0][:amount]
    available = balances[:issuing][:available][0][:amount]

    topup_amount = buffer - pending - available

    return unless topup_amount > 0

    StripeService::Topup.create({
      destination_balance: 'issuing',
      amount: topup_amount,
      currency: 'usd',
      statement_descriptor: 'Stripe Top-up'
    })

    puts "Just created a topup for #{topup_amount}"
  end
end
