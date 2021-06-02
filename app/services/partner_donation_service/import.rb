module PartnerDonationService
  class Import
    def run
      stripe_charges.each do |sc|
        ::PartnerDonationService::CreateRemotePayout.new(stripe_charge_id: sc.id).run
      end

      true
    end

    private

    def attrs
    end

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
