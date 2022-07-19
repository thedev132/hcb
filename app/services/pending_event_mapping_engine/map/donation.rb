# frozen_string_literal: true

module PendingEventMappingEngine
  module Map
    class Donation
      def run
        unmapped.find_each(batch_size: 100) do |cpt|
          ::PendingEventMappingEngine::Map::Single::Donation.new(canonical_pending_transaction: cpt).run
        end
      end

      private

      def unmapped
        CanonicalPendingTransaction.unmapped.donation
      end

    end
  end
end
