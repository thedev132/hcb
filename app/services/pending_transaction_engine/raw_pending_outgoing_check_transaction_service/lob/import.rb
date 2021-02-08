module PendingTransactionEngine
  module RawPendingOutgoingCheckTransactionService
    module Lob
      class Import
        def initialize
        end

        def run
          pending_outgoing_check_transactions.each do |poct|
            ::RawPendingOutgoingCheckTransaction.find_or_initialize_by(lob_transaction_id: poct["id"]).tap do |t|
              t.lob_transaction = poct
              t.amount = -poct["amount"] # Lob returns amounts like 10.02 or 10 (dollar.cents format with cents chopped off for round numbers). use negative since these are outgoing.
              t.date_posted = poct["date_created"]
            end.save!
          end

          nil
        end

        private

        def pending_outgoing_check_transactions
          @pending_outgoing_check_transactions ||= ::Partners::Lob::Checks::List.new(start_date: Time.now.utc - 5.years).run
        end
      end
    end
  end
end
