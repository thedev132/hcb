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

          if fee.amount_cents_as_decimal > 0

            # All emburse transactions revenue are fee waived according to historical logic
            fee.amount_cents_as_decimal = 0
            fee.reason = "REVENUE WAIVED"
            fee.save!

          end
        end

        # also deal with non-standard fee applications on plaid transactions - tends to effect older events
        plaid_ids = event.transactions.select { |t| t.fee == false }.pluck(:plaid_id)
        rpts = RawPlaidTransaction.where(plaid_transaction_id: plaid_ids)
        fees = rpts.map { |rpt| rpt.hashed_transactions.first.canonical_transaction }.map { |ct| ct.canonical_event_mapping.fees.first }.select { |fee| fee.amount_cents_as_decimal > 0 }
        fees.each { |fee| fee.amount_cents_as_decimal = 0; fee.reason = "REVENUE WAIVED"; fee.save!; }
      end

      private

      def event
        @event ||= Event.find(@event_id)
      end
    end
  end
end
