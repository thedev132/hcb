# frozen_string_literal: true

module TransactionEngine
  module CanonicalTransactionService
    module Import
      class All
        def run
          ::TransactionEngine::CanonicalTransactionService::Import::Simple.new.run
          ::TransactionEngine::CanonicalTransactionService::Import::PlaidThatLookLikeDuplicates.new.run
          ::TransactionEngine::CanonicalTransactionService::Import::EmburseThatLookLikeDuplicates.new.run
          ::TransactionEngine::CanonicalTransactionService::Import::StripeThatLookLikeDuplicates.new.run
        end
      end
    end
  end
end
