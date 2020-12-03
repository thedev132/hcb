module PendingTransactionEngine
  class Nuke
    def run
      RawPendingStripeTransaction.delete_all

      true
    end
  end
end
