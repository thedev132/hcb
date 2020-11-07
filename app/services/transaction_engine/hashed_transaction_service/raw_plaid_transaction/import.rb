module TransactionEngine
  module HashedTransactionService
    module RawPlaidTransaction
      class Import
        def run
          ::RawPlaidTransaction.find_each do |pt|
            begin
              ph = primary_hash(pt)

              attrs = {
                primary_hash: ph[0],
                raw_plaid_transaction_id: pt.id
              }

              ::HashedTransaction.find_or_initialize_by(attrs).tap do |ht|
                ht.primary_hash_input = ph[1]
              end.save!
            rescue ArgumentError => e
              puts "RawPlaidTransaction #{pt.id}: #{e}"

              raise e
            end
          end
        end

        private

        def primary_hash(pt)
          attrs = {
            date: pt.date_posted.strftime('%Y-%m-%d'),
            amount_cents: pt.amount_cents,
            memo: pt.memo.upcase
          }
          ::TransactionEngine::HashedTransactionService::PrimaryHash.new(attrs).run
        end
      end
    end
  end
end
