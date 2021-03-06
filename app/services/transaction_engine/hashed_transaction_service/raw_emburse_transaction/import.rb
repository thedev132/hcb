module TransactionEngine
  module HashedTransactionService
    module RawEmburseTransaction
      class Import
        include ::TransactionEngine::Shared

        def initialize(start_date: nil)
          @start_date = start_date || last_1_month
        end

        def run
          ::RawEmburseTransaction.where("date_posted >= ?", @start_date).find_each(batch_size: 100) do |et|
            next if et.amount_cents == 0
            next unless et.state == 'completed' # only permit completed transactions

            ph = primary_hash(et)

            ::HashedTransaction.find_or_initialize_by(raw_emburse_transaction_id: et.id).tap do |ht|
              ht.primary_hash = ph[0]
              ht.primary_hash_input = ph[1]
            end.save!
          end
        end

        private

        def primary_hash(et)
          attrs = {
            unique_bank_identifier: et.unique_bank_identifier,
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
