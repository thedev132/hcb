# frozen_string_literal: true

module TransactionEngine
  module HashedTransactionService
    module RawIncreaseTransaction
      class Import
        include ::TransactionEngine::Shared

        def initialize(start_date: nil)
          @start_date = start_date || last_1_month
        end

        def run
          ::RawIncreaseTransaction.where("date_posted >= ?", @start_date).find_each(batch_size: 100) do |rit|
            begin
              next if rit.amount_cents == 0

              ph = primary_hash(rit)

              ::HashedTransaction.find_or_initialize_by(raw_increase_transaction_id: rit.id).tap do |ht|
                ht.primary_hash = ph[0]
                ht.primary_hash_input = ph[1]
              end.save!
            rescue ArgumentError => e
              puts "RawIncreaseTransaction #{rit.id}: #{e}"

              raise e
            end
          end
        end

        private

        def primary_hash(it)
          ::TransactionEngine::HashedTransactionService::PrimaryHash.new(
            unique_bank_identifier: it.unique_bank_identifier,
            date: it.date_posted.strftime("%Y-%m-%d"),
            amount_cents: it.amount_cents,
            memo: it.memo.upcase
          ).run
        end

      end
    end
  end
end
