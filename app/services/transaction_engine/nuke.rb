module TransactionEngine
  class Nuke
    def run
      CanonicalHashedMapping.delete_all

      CanonicalTransaction.delete_all

      HashedTransaction.delete_all

      RawCsvTransaction.delete_all
      RawPlaidTransaction.delete_all
      RawEmburseTransaction.delete_all

      true
    end
  end
end
