# frozen_string_literal: true

module PendingEventMappingEngine
  module Map
    class PartnerDonation
      def run
        unmapped.find_each(batch_size: 100) do |cpt|
          next unless cpt.raw_pending_partner_donation_transaction.likely_event_id

          attrs = {
            event_id: cpt.raw_pending_partner_donation_transaction.likely_event_id,
            canonical_pending_transaction_id: cpt.id
          }
          CanonicalPendingEventMapping.create!(attrs)
        end
      end

      private

      def unmapped
        CanonicalPendingTransaction.unmapped.partner_donation
      end
    end
  end
end
