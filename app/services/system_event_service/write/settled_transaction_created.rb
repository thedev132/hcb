# frozen_string_literal: true

module SystemEventService
  module Write
    class SettledTransactionCreated
      NAME = "settledTransactionCreated"

      def initialize(canonical_transaction:)
        @canonical_transaction = canonical_transaction
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
          id: @canonical_transaction.id,
          date: @canonical_transaction.date,
          memo: @canonical_transaction.memo,
          amount_cents: @canonical_transaction.amount_cents
        }
      end
    end
  end
end
