module Temp
  module MarkEmburseRevenueFree
    class Index
      def initialize(event_id:)
        @event_id = event_id
      end

      def run
        event.canonical_transactions.each do |ct|
          hashed_transactions = ct.hashed_transactions.where("raw_emburse_transaction_id is not null")

          next unless hashed_transactions.present?

          hashed_transactions.first

          ret = hashed_transactions.first.raw_emburse_transaction

          next unless ret.present?

          fee = ct.fees.first

          # All emburse transactions are fee waived according to historical logic
          fee.amount_cents_as_decimal = 0
          fee.reason = "REVENUE WAIVED"
          fee.save!
        end
      end

      private

      def event
        @event ||= Event.find(@event_id)
      end
    end
  end
end
