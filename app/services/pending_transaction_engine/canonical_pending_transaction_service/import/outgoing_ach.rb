module PendingTransactionEngine
  module CanonicalPendingTransactionService
    module Import
      class OutgoingAch
        def run
          raw_pending_outgoing_ach_transactions_ready_for_processing.find_each do |rpoct|
            ActiveRecord::Base.transaction do
              attrs = {
                date: rpoct.date,
                memo: rpoct.memo,
                amount_cents: rpoct.amount_cents,
                raw_pending_outgoing_ach_transaction_id: rpoct.id
              }
              ct = ::CanonicalPendingTransaction.create!(attrs)
            end
          end
        end

        private

        def raw_pending_outgoing_ach_transactions_ready_for_processing
          @raw_pending_outgoing_ach_transactions_ready_for_processing ||= begin
            return RawPendingOutgoingAchTransaction.all if previously_processed_raw_pending_outgoing_ach_transactions_ids.length < 1

            RawPendingOutgoingAchTransaction.where('id not in(?)', previously_processed_raw_pending_outgoing_ach_transactions_ids)
          end
        end

        def previously_processed_raw_pending_outgoing_ach_transactions_ids
          @previously_processed_raw_pending_outgoing_ach_transactions_ids ||= ::CanonicalPendingTransaction.outgoing_ach.pluck(:raw_pending_outgoing_ach_transaction_id)
        end
      end
    end
  end
end
