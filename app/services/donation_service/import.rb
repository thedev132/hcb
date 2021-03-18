module DonationService
  class Import
    def run
      stripe_charges.each do |sc|
        puts sc.payment_intent
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
