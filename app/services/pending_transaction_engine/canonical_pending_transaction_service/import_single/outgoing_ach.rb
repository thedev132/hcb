# frozen_string_literal: true

module PendingTransactionEngine
  module CanonicalPendingTransactionService
    module ImportSingle
      class OutgoingAch
        def initialize(raw_pending_outgoing_ach_transaction:)
          @rpoct = raw_pending_outgoing_ach_transaction
        end

        def run
          attrs = {
            date: @rpoct.date,
            memo: @rpoct.memo,
            amount_cents: @rpoct.amount_cents,
            raw_pending_outgoing_ach_transaction_id: @rpoct.id
          }
          ct = ::CanonicalPendingTransaction.create!(attrs)
        end

      end
    end
  end
end
