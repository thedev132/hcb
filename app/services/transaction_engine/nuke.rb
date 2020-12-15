module TransactionEngine
  class Nuke
    def run
      CanonicalPendingDeclinedMapping.delete_all
      CanonicalPendingSettledMapping.delete_all

      CanonicalHashedMapping.delete_all

      CanonicalTransaction.delete_all

      HashedTransaction.delete_all

      RawCsvTransaction.delete_all
      RawPlaidTransaction.delete_all
      RawEmburseTransaction.delete_all
      RawStripeTransaction.delete_all

      true
    end
  end
end
