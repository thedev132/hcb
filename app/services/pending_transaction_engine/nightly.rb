module PendingTransactionEngine
  class Nightly
    def run
      # 1 raw imports
      import_raw_pending_stripe_transactions!
    end

    private

    def import_raw_pending_stripe_transactions!
      ::PendingTransactionEngine::RawPendingStripeTransactionService::Stripe::Import.new.run
    end
  end
end
