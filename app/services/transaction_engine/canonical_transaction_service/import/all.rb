module TransactionEngine
  module CanonicalTransactionService
    module Import
      class All
        def run
          ::TransactionEngine::CanonicalTransactionService::Import::Simple.new.run
          ::TransactionEngine::CanonicalTransactionService::Import::PlaidThatLookLikeDuplicates.new.run
        end
      end
    end
  end
end
