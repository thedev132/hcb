class TopupStripeJob < ApplicationJob
  queue_as :default

  def perform
    # amount of floating money that should be in stripe at any given time
    # (msw) note this number is arbitrary at the time of writing– we have no
    # clue how much buffer we'll need so I'll be manually updating this while
    # we find our footing on stripe issuing
    buffer = 40_000 * 100

    # amount of money currently in stripe
    balances = StripeService::Balance.retrieve
    pending = balances[:issuing].try(:[], :pending).try(:[], 0).try(:[], :amount) || 0 # new API changed this - it is not included when 0
    available = balances[:issuing][:available][0][:amount]

    # amount of money already enroute to stripe through existing topups
    topups = Stripe::Topup.list(status: :pending)
    enroute_sum = topups[:data].sum(&:amount)

    # stripe TXs can get created 1 to 30 days after approval, so let's grab any
    # authorization that's pending
    expected_tx_sum = 0
    authorizations = StripeService::Issuing::Authorization.list(status: :pending)
    authorizations.auto_paging_each do |auth|
      expected_tx_sum += auth[:amount] if auth[:approved] &&
                                          auth[:transactions].empty?
    end

    topup_amount = buffer - pending - available + expected_tx_sum - enroute_sum

    puts "topup amount == #{topup_amount}"
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
