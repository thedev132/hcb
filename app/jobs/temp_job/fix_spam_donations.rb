module TempJob
  class FixSpamDonations < ApplicationJob
    def perform
      ::Donation.not_succeeded.where(event_id: 183, amount: 100).find_each(batch_size: 100) do |d|
        ::StripeService::PaymentIntent.cancel(d.stripe_payment_intent_id) rescue nil
        d.destroy!
      end
    end
  end
end
