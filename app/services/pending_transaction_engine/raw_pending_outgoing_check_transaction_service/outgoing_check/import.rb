module PendingTransactionEngine
  module RawPendingOutgoingCheckTransactionService
    module OutgoingCheck
      class Import
        def initialize
        end

        def run
          pending_outgoing_check_transactions.each do |poct|
            ::RawPendingOutgoingCheckTransaction.find_or_initialize_by(check_transaction_id: poct.id.to_s).tap do |t|
              t.amount_cents = -poct.amount
              t.date_posted = poct.created_at
            end.save!
          end

          nil
        end

        private

        def pending_outgoing_check_transactions
          @pending_outgoing_check_transactions ||= Check.all
        end
      end
    end
  end
end
