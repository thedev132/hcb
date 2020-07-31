class TopupStripeJob < ApplicationJob
  queue_as :default

  def perform
    # amount of floating money that should be in stripe at any given time
    buffer = 1000 * 100

    # amount of money currently in stripe
    balances = StripeService::Balance.retrieve
    pending = balances[:issuing][:pending][0][:amount]
    available = balances[:issuing][:available][0][:amount]

    # stripe TXs can get created up to 48 hours after approval, so let's count
    # amount of approvals without TXs in the past 2 days
    expected_tx_sum = 0
    authorizations = StripeService::Issuing::Authorization.list(status: :pending)
    authorizations[:data].each do |auth|
      expected_tx_sum += auth[:amount] if auth[:approved] &&
                                          auth[:transactions].empty?
    end

    topup_amount = buffer - pending - available + expected_tx_sum

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
