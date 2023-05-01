# frozen_string_literal: true

module TransactionEngine
  module CanonicalTransactionService
    module Import
      class All
        def run
          HashedTransaction.uncanonized.each do |ht|
            CanonicalTransaction.create!(
              date: ht.date,
              memo: ht.memo,
              amount_cents: ht.amount_cents,
              canonical_hashed_mappings: [CanonicalHashedMapping.new(hashed_transaction: ht)],
              transaction_source: ht.raw_plaid_transaction || ht.raw_emburse_transaction || ht.raw_stripe_transaction || ht.raw_csv_transaction || ht.raw_increase_transaction
            )
          end

          # |  old transaction duplicate detection
          # v
          # ::TransactionEngine::CanonicalTransactionService::Import::Simple.new.run
          # ::TransactionEngine::CanonicalTransactionService::Import::PlaidThatLookLikeDuplicates.new.run
          # ::TransactionEngine::CanonicalTransactionService::Import::EmburseThatLookLikeDuplicates.new.run
          # ::TransactionEngine::CanonicalTransactionService::Import::StripeThatLookLikeDuplicates.new.run
          # ::TransactionEngine::CanonicalTransactionService::Import::IncreaseThatLookLikeDuplicates.new.run
        end

      end
    end
  end
end
