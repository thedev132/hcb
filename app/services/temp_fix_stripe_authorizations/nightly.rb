module TempFixStripeAuthorizations
  class Nightly
    def run
      ids = Set.new

      StripeAuthorization.find_each do |sa|
        next if sa.remote_stripe_transaction_amount_cents.nil?

        next if sa.remote_stripe_transaction_amount_cents == -sa.amount
        ids.add(sa.id)

        pp ids
      end

      ids
    end
  end
end
