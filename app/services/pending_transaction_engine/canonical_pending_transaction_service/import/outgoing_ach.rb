# frozen_string_literal: true

module PendingTransactionEngine
  module CanonicalPendingTransactionService
    module Import
      class OutgoingAch
        def run
          raw_pending_outgoing_ach_transactions_ready_for_processing.find_each(batch_size: 100) do |rpoct|
            PendingTransactionEngine::CanonicalPendingTransactionService::ImportSingle::OutgoingAch.new(raw_pending_outgoing_ach_transaction: rpoct).run
          end
        end

        private

        def raw_pending_outgoing_ach_transactions_ready_for_processing
          @raw_pending_outgoing_ach_transactions_ready_for_processing ||= begin
            return RawPendingOutgoingAchTransaction.all if previously_processed_raw_pending_outgoing_ach_transactions_ids.length < 1

            RawPendingOutgoingAchTransaction.where("id not in(?)", previously_processed_raw_pending_outgoing_ach_transactions_ids)
          end
        end

        def previously_processed_raw_pending_outgoing_ach_transactions_ids
          @previously_processed_raw_pending_outgoing_ach_transactions_ids ||= ::CanonicalPendingTransaction.outgoing_ach.pluck(:raw_pending_outgoing_ach_transaction_id)
        end

      end
    end
  end
end
