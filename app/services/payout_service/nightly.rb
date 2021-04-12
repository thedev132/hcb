module PayoutService
  class Nightly
    def run
      ::Donation.in_transit.missing_payout.each do |donation|
        ::PayoutService::Donation::Create.new(donation_id: donation.id).run
      end

      ::Invoice.paid_v2.missing_payout.each do |invoice|
        ::PayoutService::Invoice::Create.new(invoice_id: invoice.id).run
      end
    end
  end
end
