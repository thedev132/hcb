# frozen_string_literal: true

module PendingEventMappingEngine
  module Map
    class Invoice
      def run
        unmapped.find_each(batch_size: 100) do |cpt|
          ::PendingEventMappingEngine::Map::Single::Invoice.new(canonical_pending_transaction: cpt).run
        end
      end

      private

      def unmapped
        CanonicalPendingTransaction.unmapped.invoice
      end

    end
  end
end
