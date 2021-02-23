module DonationService
  class Nightly
    def initialize
    end

    def run
      ids = []
      Donation.not_succeeded.find_each(batch_size: 100) do |d|
        status = fetch_status(donation: d)

        if d.status != status
          puts "=" * 50
          puts d.id

          ids.push(d.id)
        end
      end

      ids
    end

    private

    def fetch_status(donation:)
      remote_payment_intent(donation: donation).status
    end

    def remote_payment_intent(donation:)
      ::Partners::Stripe::PaymentIntents::Show.new(id: donation.stripe_payment_intent_id).run
    end
  end
end
