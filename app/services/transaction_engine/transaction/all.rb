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

      def canonical_transaction_ids
        @canonical_transaction_ids ||= canonical_event_mappings.pluck(:canonical_transaction_id)
      end

      def canonical_transactions_grouped
        q = <<-SQL
          select 
            COALESCE(ct.hcb_code, CAST(ct.id AS text)) as hcb_code
            ,array_to_string(array_agg(ct.date), ', ') as date
            ,array_to_string(array_agg(ct.memo), ', ') as memo
            ,sum(ct.amount_cents) as amount_cents
            ,(sum(ct.amount_cents) / 100.0) as amount
          from 
            canonical_transactions ct
          where ct.id in (
            select
              cem.canonical_transaction_id
            from
              canonical_event_mappings cem
            where
              cem.event_id = #{event.id}
          )
          group by
            COALESCE(ct.hcb_code, CAST(ct.id AS text))
        SQL
        ActiveRecord::Base.connection.execute(q)
      end
    end
  end
end
