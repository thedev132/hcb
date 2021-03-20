# frozen_string_literal: true

module TransactionEngine
  module Transaction
    class All
      def initialize(event_id:)
        @event_id = event_id
      end

      def run
        canonical_transactions
      end

      private

      def event
        @event ||= Event.find(@event_id)
      end

      def canonical_event_mappings
        @canonical_event_mappings ||= CanonicalEventMapping.where(event_id: event.id)
      end

      def canonical_transactions
        @canonical_transactions ||= CanonicalTransaction.includes(:receipts).where(id: canonical_event_mappings.pluck(:canonical_transaction_id)).order("date desc, id desc")
      end

      def canonical_transactions_grouped
        q = <<-SQL
          select 
            hcb_code
            ,array_to_string(array_agg(date), ', ')
            ,array_to_string(array_agg(memo), ', ')
            ,sum(amount_cents) as amount_cents
          from 
            canonical_transactions
          group by
            hcb_code
        SQL
        ActiveRecord::Base.connection.execute(q)
      end
    end
  end
end
