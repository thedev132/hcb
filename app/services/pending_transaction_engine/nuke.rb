module PendingTransactionEngine
  class Nuke
    def run
      CanonicalPendingTransaction.delete_all
      RawPendingStripeTransaction.delete_all

      true
    end
  end
end
