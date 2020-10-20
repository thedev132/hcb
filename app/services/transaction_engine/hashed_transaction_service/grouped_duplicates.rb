module TransactionEngine
  module HashedTransactionService
    class GroupedDuplicates
      def run
        ::TransactionEngine::HashedTransactionService::Duplicates.new.run.group_by(&:primary_hash).values
      end
    end
  end
end
