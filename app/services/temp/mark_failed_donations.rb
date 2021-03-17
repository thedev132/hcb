module Temp
  class MarkFailedDonations
    def run
      ::Partners::Stripe::Charges::List.new.run do |sc|
        if sc.status == "failed" && sc.payment_intent.present?
          d = Donation.where(stripe_payment_intent_id: sc.payment_intent).first

          d.mark_failed! if d && !d.failed?
        end
      end
    end
  end
end
