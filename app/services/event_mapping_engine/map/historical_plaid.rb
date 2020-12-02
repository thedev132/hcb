module EventMappingEngine
  module Map
    class HistoricalPlaid
      def run
        RawPlaidTransaction.where(plaid_transaction_id: in_common_plaid_transaction_ids).find_each do |raw_plaid_transaction|

          Airbrake.notify("There was more than 1 hashed transaction for raw_plaid_transaction: #{raw_plaid_transaction.id}") if raw_plaid_transaction.hashed_transactions.length > 1

          next if raw_plaid_transaction.hashed_transactions.length > 1 # skip.
          next if raw_plaid_transaction.hashed_transactions.length < 1 # skip. these are raw transactions that haven't yet been hashed for some reason. TODO. surface these somehow elsewhere

          canonical_transaction_id = raw_plaid_transaction.hashed_transactions.first.canonical_transaction.id

          historical_transaction = Transaction.with_deleted.find_by(plaid_id: raw_plaid_transaction.plaid_transaction_id)

          next unless historical_transaction # TODO: surface this data somewhere. if missing this means historical data is missing in the old transaction system

          event_id = historical_transaction.event.try(:id)

          next unless event_id

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

      def deprecated_transaction_plaid_ids
        @deprecated_transaction_plaid_ids ||= Transaction.with_deleted.pluck(:plaid_id)
      end

      def raw_plaid_transaction_ids
        @raw_plaid_transaction_ids ||= RawPlaidTransaction.pluck(:plaid_transaction_id)
      end

      def in_common_plaid_transaction_ids
        @in_common_plaid_transaction_ids ||= deprecated_transaction_plaid_ids && raw_plaid_transaction_ids
      end
    end
  end
end
