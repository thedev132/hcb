# frozen_string_literal: true

module PendingTransactionEngine
  module RawPendingOutgoingAchTransactionService
    module OutgoingAch
      class Import
        def initialize
        end

        def run
          pending_outgoing_ach_transactions.each do |poat|
            PendingTransactionEngine::RawPendingOutgoingAchTransactionService::OutgoingAch::ImportSingle.new(ach_transfer: poat).run
          end

          nil
        end

        private

        def pending_outgoing_ach_transactions
          @pending_outgoing_ach_transactions ||= AchTransfer.all
        end

      end
    end
  end
end
