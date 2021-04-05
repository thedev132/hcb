module DonationService
  class Refunds
    def run
      ids = []

      ::Donation.deposited.each do |donation|
        ids.push(donation.id) if donation.remote_refunded?
      end

      ids
    end
  end
end
