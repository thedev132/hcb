module DonationService
  class Refunds
    def run
      ::Donation.deposited.each do |donation|
        if donation.remote_funded?

          ::DonationService::Refund.new(donation: donation).run

        end
      end
    end
  end
end
