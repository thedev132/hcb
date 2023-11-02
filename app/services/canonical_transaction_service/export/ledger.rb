# frozen_string_literal: true

require "libledger"

module CanonicalTransactionService
  module Export
    class Ledger
      BATCH_SIZE = 1000

      def initialize(event_id:)
        @event_id = event_id
      end

      def run
        entries = []
        event.canonical_transactions.order("date desc").each do |ct|
          if ct.amount_cents <= 0
            entries.push(
              ::Ledger::Entry.new(
                name: ct.local_hcb_code.memo,
                date: ct.date,
                actions: [
                  { name: "Expenses", amount: (ct.amount_cents.abs.to_f / 100).to_s }
                ]
              )
            )
          else
            entries.push(
              ::Ledger::Entry.new(
                name: ct.local_hcb_code.memo,
                date: ct.date,
                actions: [
                  { name: "Income", amount: (ct.amount_cents.to_f / 100).to_s }
                ]
              )
            )
          end
        end
        ledger = ::Ledger::Journal.new(entries:)
        return ledger.to_s
      end

      private

      def event
        @event ||= Event.find(@event_id)
      end

    end
  end
end
