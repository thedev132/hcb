module PayoutService
  class Nightly
    def run
      ::Donation.in_transit.missing_payout.each do |donation|
        ::PayoutService::Donation::Create.new(donation_id: donation.id).run
      end

      ::Invoice.paid.where("payout_id is null and payout_creation_balance_net is not null").each do |invoice|
        ::PayoutService::Invoice::Create.new(invoice_id: invoice.id).run
      end
    end
  end
end
