module PayoutService
  class Nightly
    def run
      Donation.succeeded.where("payout_id is null").each do |donation|
        # 1. fetch payment intent
        payment_intent = ::Partners::Stripe::PaymentIntents::Show.new(id: donation.stripe_payment_intent_id).run

        # 2. get remote available_on timestamp
        available_on = payment_intent.charges.data.first.balance_transaction.available_on

        # 3. create payout if time is ready. TODO: move this into the scope (by later moving the available_on into its own field on the donation table)
        donation.create_payout! if ready_for_payout?(available_on: available_on)
      end
    end

    private

    def ready_for_payout?(available_on:)
      (Util.unixtime(available_on) + 1.days) < Time.now
    end
  end
end
