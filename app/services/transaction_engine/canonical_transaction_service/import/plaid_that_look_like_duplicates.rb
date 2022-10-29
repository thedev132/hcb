# frozen_string_literal: true

module TransactionEngine
  module CanonicalTransactionService
    module Import
      class PlaidThatLookLikeDuplicates
        def run
          unprocessed_plaid_with_duplicate_hashes.find_each(batch_size: 100) do |ht|
            next if actual_duplicate_already_processed(ht)

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

        def unprocessed_plaid_with_duplicate_hashes
          plaid_hts.where("id in (?)", diff_ht_ids)
        end

        def diff_ht_ids
          @diff_ht_ids ||= duplicate_ht_ids - previously_processed_ht_ids
        end

        def plaid_hts
          ::HashedTransaction.where.not(raw_plaid_transaction_id: nil)
        end

        def duplicate_ht_ids
          @duplicate_ht_ids ||= ::TransactionEngine::HashedTransactionService::Duplicates.new.run.pluck(:id)
        end

        def previously_processed_ht_ids
          @previously_processed_ht_ids ||= ::CanonicalHashedMapping.pluck(:hashed_transaction_id)
        end

        def actual_duplicate_already_processed(hashed_transaction)
          # For some reason we imported transactions from the same bank
          # account 2 different connections. Some historical reasons for this happening
          # - Plaid authentication info changed (2 separate plaid connections)
          # - Plaid has downtime, so transactions were imported by CSV. Then later when Plaid is
          #   back online, transactions that had already been imported from CSV are sent again from Plaid.
          #
          # All those transactions would be actual duplicates (they'd each have 1
          # transaction from each plaid connection)
          #
          # If the same primary hash is seen in the same plaid account, then we don't consider those duplicates.
          # However, we only care if the duplicate has already been processed (i.e. a CanonicalTransaction has been made for it),
          # because at least one of the duplicates should be processed.
          ::HashedTransaction.includes(:canonical_transaction)
                             .where.not(raw_plaid_transaction_id: hashed_transaction.raw_plaid_transaction_id)
                             .where(primary_hash: hashed_transaction.primary_hash)
                             .map(&:canonical_transaction)
                             .any?
        end

      end
    end
  end
end
