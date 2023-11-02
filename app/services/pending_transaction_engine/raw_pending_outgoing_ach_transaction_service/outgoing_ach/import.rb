# frozen_string_literal: true

module PendingTransactionEngine
  module RawPendingOutgoingAchTransactionService
    module OutgoingAch
      class Import
        def initialize
        end

        def run
          pending_outgoing_ach_transactions.find_each(batch_size: 100) do |poat|
            PendingTransactionEngine::RawPendingOutgoingAchTransactionService::OutgoingAch::ImportSingle.new(ach_transfer: poat).run
          end

          nil
        end

        private

        def pending_outgoing_ach_transactions
          @pending_outgoing_ach_transactions ||= AchTransfer.in_transit.or(AchTransfer.pending.where(scheduled_on: nil))
        end

      end
    end
  end
end
