module PendingTransactionEngine
  module CanonicalPendingTransactionService
    module Import
      class All
        def run
          ::PendingTransactionEngine::CanonicalPendingTransactionService::Import::Simple.new.run
        end
      end
    end
  end
end
