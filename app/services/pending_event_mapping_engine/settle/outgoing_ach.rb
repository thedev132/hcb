# frozen_string_literal: true

module PendingEventMappingEngine
  module Settle
    class OutgoingAch
      def run
        unsettled.find_each(batch_size: 100) do |cpt|
          ct = cpt.local_hcb_code.canonical_transactions.first

          next unless ct

          CanonicalPendingTransactionService::Settle.new(
            canonical_transaction: ct,
            canonical_pending_transaction: cpt
          ).run!
        end
      end

      private

      def unsettled
        CanonicalPendingTransaction.unsettled.outgoing_ach
      end

    end
  end
end
