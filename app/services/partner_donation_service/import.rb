module PartnerDonationService
  class Import
    def run
      stripe_charges.each do |sc|
        # TODO: import into a process to generate payouts somehow
      end
    end

    private

    def stripe_charges
      ::Partners::Stripe::Charges::List.new(list_attrs).run
    end

    def list_attrs
      {
        start_date: Time.now.utc - 3.years
      }
    end
  end
end
