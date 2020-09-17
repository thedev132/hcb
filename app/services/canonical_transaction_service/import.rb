module CanonicalTransactionService
  class Import
    def run
      hashed_transactions_ready_for_processing.find_each do |ht|

        attrs = {
          date: ht.date,
          memo: ht.memo,
          amount_cents: ht.amount_cents
        }
        ::CanonicalTransaction.create!(attrs)

      end
    end

    private

    # TODO: additionally remove already processed canonical transactions
    def hashed_transactions_ready_for_processing
      ::HashedTransaction.where('id is not in (?)', duplicate_hashed_transaction_ids)
    end

    def duplicate_hashed_transaction_ids
      @duplicate_hashed_transaction_ids ||= ::HashedTransactionService::Duplicates.new.run.pluck(:id)
    end
  end
end
