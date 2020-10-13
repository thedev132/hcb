module TransactionEngine
  module RawEmburseTransactionService
    module Emburse
      class Import
        def initialize(from: nil)
          @from = from
        end

        def run
          emburse_transactions.each do |t|
            ::RawEmburseTransaction.find_or_initialize_by(emburse_transaction_id: t[:id]).tap do |et|
              et.emburse_transaction = t
              et.amount = t[:amount]
              et.date_posted = t[:time]
              et.state = t[:state]
            end.save!
          end

          nil
        end

        private

        def emburse_transactions
          @emburse_transactions ||= ::Partners::Emburse::Transactions::List.new(before: before, after: after).run
        end

        def after
          from.iso8601
        end

        def before
          (from + 10.days).iso8601
        end

        def from
          @from ||= 10.days.ago
        end
      end
    end
  end
end
