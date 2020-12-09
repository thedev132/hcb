module EventMappingEngine
  module Map
    class StripeTransactions
      def run
        RawStripeTransaction.find_each do |raw_stripe_transaction|

          Airbrake.notify("There was more than 1 hashed transaction for raw_stripe_transaction: #{raw_stripe_transaction.id}") if raw_stripe_transaction.hashed_transactions.length > 1

          next if raw_stripe_transaction.hashed_transactions.length > 1 # skip.
          next if raw_stripe_transaction.hashed_transactions.length < 1 # skip. these are raw transactions that haven't yet been hashed for some reason. TODO. surface these somehow elsewhere

          next unless raw_stripe_transaction.likely_event_id

          # check if current mapping
          current_canonical_event_mapping = ::CanonicalEventMapping.find_by(canonical_transaction_id: canonical_transaction_id)

          # raise error if discrepancy in event that was being set
          raise ArgumentError, "CanonicalTransaction #{canonical_transaction_id} already has an event mapping but as event #{current_canonical_event_mapping.event_id} (attempted to otherwise set event #{event_id})" if current_canonical_event_mapping.try(:event_id) && current_canonical_event_mapping.event_id != event_id

          next if current_canonical_event_mapping

          attrs = {
            canonical_transaction_id: canonical_transaction_id,
            event_id: event_id
          }

          ::CanonicalEventMapping.create!(attrs)
        end
      end

      private

      def raw_stripe_transaction_ids
        @raw_stripe_transaction_ids ||= RawStripeTransaction.pluck(:stripe_transaction_id)
      end

      def in_common_stripe_transaction_ids
        @in_common_stripe_transaction_ids ||= deprecated_transaction_stripe_ids && raw_stripe_transaction_ids
      end
    end
  end
end
