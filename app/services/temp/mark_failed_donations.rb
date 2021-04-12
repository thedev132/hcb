module Temp
  class MarkFailedDonations
    def run
      ::Partners::Stripe::Charges::List.new(start_date: start_date).run do |sc|
        if sc.status == "failed" && sc.payment_intent.present?
          d = Donation.where(stripe_payment_intent_id: sc.payment_intent).first

          d.mark_failed! if d && !d.failed? && !d.deposited?
        end
      end
    end

    private

    def start_date
      Time.utc(2019, 12, 1) # first donation occurred 2019-12
    end
  end
end
