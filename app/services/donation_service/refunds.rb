module DonationService
  class Refunds
    def run
      ::Donation.deposited.each do |donation|
        ::DonationJob::Refund.perform_later(donation.id) if donation.remote_refunded?
      end
    end
  end
end
