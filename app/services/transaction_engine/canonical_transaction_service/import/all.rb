module TransactionEngine
  module CanonicalTransactionService
    module Import
      class All
        def run
          ::TransactionEngine::CanonicalTransactionService::Import::Simple.new.run
        end
      end
    end
  end
end
