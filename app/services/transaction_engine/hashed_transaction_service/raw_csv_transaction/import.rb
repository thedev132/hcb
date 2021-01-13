module TransactionEngine
  module HashedTransactionService
    module RawCsvTransaction
      class Import
        def run
          ::RawCsvTransaction.find_each do |ct|
            ph = primary_hash(ct)

            ::HashedTransaction.find_or_initialize_by(raw_csv_transaction_id: ct.id).tap do |ht|
              ht.primary_hash = ph[0]
              ht.primary_hash_input = ph[1]
            end.save!
          end
        end

        private

        def primary_hash(ct)
          attrs = {
            unique_bank_identifier: ct.unique_bank_identifier,
            date: ct.date_posted.strftime('%Y-%m-%d'),
            amount_cents: ct.amount_cents,
            memo: ct.memo.upcase
          }
          ::TransactionEngine::HashedTransactionService::PrimaryHash.new(attrs).run
        end
      end
    end
  end
end
