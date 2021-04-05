module DonationService
  class Refunds
    def run
      ::Donation.deposited.each do |donation|
        if donation.remote_refunded?

          ::DonationService::Refund.new(donation: donation).run

        end
      end
    end
  end
end
