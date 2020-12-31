module TransactionEngine
  module HashedTransactionService
    module RawEmburseTransaction
      class Import
        def initialize(start_date: nil)
          @start_date = start_date || Time.now.utc - 1.month
        end

        def run
          ::RawEmburseTransaction.where("date_posted >= ?", @start_date).find_each do |et|
            next if et.amount_cents == 0
            next unless et.state == 'completed' # only permit completed transactions

            ph = primary_hash(et)

            attrs = {
              primary_hash: ph[0],
              raw_emburse_transaction_id: et.id
            }
            ::HashedTransaction.find_or_initialize_by(attrs).tap do |ht|
              ht.primary_hash_input = ph[1]
            end.save!
          end
        end

        private

        def primary_hash(et)
          attrs = {
            date: et.date_posted.strftime('%Y-%m-%d'),
            amount_cents: et.amount_cents,
            memo: et.memo.upcase
          }

          ::TransactionEngine::HashedTransactionService::PrimaryHash.new(attrs).run
        end
      end
    end
  end
end
