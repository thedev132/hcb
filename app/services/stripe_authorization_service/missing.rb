module StripeAuthorizationService
  class Missing
    def run
      pending_stripe_transactions.each do |t|
        ::StripeAuthorization.find_or_initialize_by(stripe_id: t[:id]).tap do |sa|
          if sa.new_record?
            sa.sync_from_stripe!
            sa.save!
          end
        end
      end

      nil
    end

    private

    def pending_stripe_transactions
      @pending_stripe_transactions ||= ::Partners::Stripe::Issuing::Authorizations::List.new.run
    end
  end
end
