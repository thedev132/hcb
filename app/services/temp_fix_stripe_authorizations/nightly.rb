module TempFixStripeAuthorizations
  class Nightly
    def run
      ids = Set.new

      StripeAuthorization.approved.find_each do |sa|
        next if sa.remote_stripe_transaction_amount_cents.nil?
        next if sa.remote_stripe_transaction_amount_cents == -sa.amount
        next if sa.remote_stripe_transaction_amount_cents == 0

        ids.add(sa.id)

        # safe to change since it is just inverted - should be opposite
        if sa.remote_stripe_transaction_amount_cents == sa.amount
          sa.amount = -sa.amount
          sa.save! # sync from stripe is overriding this
        end
      end

      ids
    end
  end
end
