module PayoutService
  class Nightly
    def run
      Donation.succeeded.where("payout_id is null").each do |d|
        # 1. get remote available_on timestamp
        pi = ::Partners::Stripe::PaymentIntents::Show.new(id: d.stripe_payment_intent_id).run
        available_on = pi.charges.data.first.balance_transaction.available_on

        # 2. create payout
        donation.create_payout! if ready_for_payout?(available_on: available_on)
      end
    end

    private

    def ready_for_payout?(available_on:)
      (Util.unixtime(available_on) + 1.days) < Time.now
    end
  end
end
