# frozen_string_literal: true

module TransactionEngine
  module CanonicalTransactionService
    module Import
      class PlaidThatLookLikeDuplicates
        def run
          unprocessed_plaid_with_duplicate_hashes.find_each(batch_size: 100) do |ht|
            # For some reason we imported transactions from the same bank
            # account through 2 different plaid connections. All those
            # transactions would be actual duplicates (they'd each have 1
            # transaction from each plaid connection)

            next unless not_actual_duplicate(ht)

            ActiveRecord::Base.transaction do
              attrs = {
                date: ht.date,
                memo: ht.memo,
                amount_cents: ht.amount_cents
              }
              ct = ::CanonicalTransaction.create!(attrs)

              attrs = {
                canonical_transaction_id: ct.id,
                hashed_transaction_id: ht.id
              }
              ::CanonicalHashedMapping.create!(attrs)
            end
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

        def not_actual_duplicate(hashed_transaction)
          # true if it's in the same plaid account
          # false if it's in a different plaid account
          ::HashedTransaction.where(raw_plaid_transaction_id: hashed_transaction.raw_plaid_transaction_id,
                                    primary_hash: hashed_transaction.primary_hash).any?
        end
      end
    end
  end
end
