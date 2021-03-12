require "csv"

module FeeService
  module Report
    class Csv
      include ActionView::Helpers

      def initialize(event_id:)
        @event_id = event_id

        @tally = 0.0
      end

      def run
        Enumerator.new do |y|
          y << header.to_s

          event.fees.includes(canonical_event_mapping: :canonical_transaction).order("canonical_transactions.date asc, canonical_transactions.id asc").each do |f|
            y << row(f).to_s
          end
        end
      end

      private

      def inc(fee_amount_cents_as_decimal)
        @tally += fee_amount_cents_as_decimal
      end

      def dec(amount_cents)
        @tally -= amount_cents
      end

      def event
        @event ||= Event.find(@event_id)
      end

      def headers
        [
          :date,
          :memo,
          :amount,
          :fee_percentage,
          :fee_amount,
          :running_fee
        ]
      end

      def header
        ::CSV::Row.new(headers, [
          "date",
          "memo",
          "amount",
          "fee_percentage",
          "fee_amount",
          "running_fee"
        ], true)
      end

      def row(f)
        inc(f.amount_cents_as_decimal)

        dec(-f.canonical_transaction.amount_cents) if f.hack_club_fee?

        ::CSV::Row.new(headers, [
          f.canonical_transaction.date,
          f.canonical_transaction.smart_memo,
          f.canonical_transaction.amount,
          ActionController::Base.helpers.number_to_percentage(f.event_sponsorship_fee * 100.0, precision: 1),
          ActionController::Base.helpers.number_with_precision(f.amount_cents_as_decimal / 100.0, precision: 4),
          ActionController::Base.helpers.number_with_precision(@tally / 100.0, precision: 4)
        ])
      end
    end
  end
end
