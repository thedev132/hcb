module CanonicalTransactionService
  class Import
    def run
      hashed_transactions_ready_for_processing.find_each do |ht|

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

    def hashed_transactions_ready_for_processing
      ::HashedTransaction.where('id not in (?)', duplicate_hashed_transaction_ids + previously_processed_hashed_transaction_ids)
    end

    def duplicate_hashed_transaction_ids
      @duplicate_hashed_transaction_ids ||= ::HashedTransactionService::Duplicates.new.run.pluck(:id)
    end

    def previously_processed_hashed_transaction_ids
      @previously_processed_hashed_transaction_ids ||= ::CanonicalHashedMapping.pluck(:hashed_transaction_id)
    end
  end
end
