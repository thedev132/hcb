# frozen_string_literal: true

module SystemEventService
  module Write
    class PendingTransactionCreated
      NAME = "pendingTransactionCreated"

      def initialize(canonical_pending_transaction:)
        @canonical_pending_transaction = canonical_pending_transaction
      end

      def run
        ::SystemEventService::Create.new(attrs).run
      end

      private

      def attrs
        {
          name: name,
          properties: properties
        }
      end

      def name
        NAME
      end

      def properties
        {
          canonical_pending_transaction: {
            id: @canonical_pending_transaction.id,
            date: @canonical_pending_transaction.date,
            memo: @canonical_pending_transaction.memo,
            amount_cents: @canonical_pending_transaction.amount_cents
          }
        }
      end
    end
  end
end
