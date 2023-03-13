# frozen_string_literal: true

module TransactionEngine
  module CanonicalTransactionService
    module Import
      class Simple
        def run
          hashed_transactions_ready_for_processing.find_each(batch_size: 100) do |ht|
            attrs = {
              date: ht.date,
              memo: ht.memo,
              amount_cents: ht.amount_cents,
              canonical_hashed_mappings: [CanonicalHashedMapping.new(hashed_transaction: ht)]
            }
            ::CanonicalTransaction.create!(attrs)
          end
        end

        private

        def hashed_transactions_ready_for_processing
          ::HashedTransaction.where.not(id: duplicate_hashed_transaction_ids + previously_processed_hashed_transaction_ids)
        end

        def duplicate_hashed_transaction_ids
          @duplicate_hashed_transaction_ids ||= ::TransactionEngine::HashedTransactionService::Duplicates.new.run.pluck(:id)
        end

        def previously_processed_hashed_transaction_ids
          @previously_processed_hashed_transaction_ids ||= ::CanonicalHashedMapping.pluck(:hashed_transaction_id)
        end

      end
    end
  end
end
