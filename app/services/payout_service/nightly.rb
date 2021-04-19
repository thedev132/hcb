module PayoutService
  class Nightly
    def run
      ::Donation.in_transit.missing_payout.each do |donation|
        ::PayoutJob::Donation.perform_later(donation.id)
      end

      ::Invoice.paid_v2.missing_payout.each do |invoice|
        ::PayoutJob::Invoice.perform_later(invoice.id)
      end
    end
  end
end
