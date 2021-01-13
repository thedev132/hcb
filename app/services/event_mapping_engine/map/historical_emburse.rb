module EventMappingEngine
  module Map
    class HistoricalEmburse
      include ::TransactionEngine::Shared

      def initialize(start_date: nil)
        @start_date = start_date || last_1_month
      end

      def run
        RawEmburseTransaction.where(emburse_transaction_id: in_common_emburse_transaction_ids).find_each do |raw_emburse_transaction|

          raise ArgumentError, "There was more than 1 hashed transaction for raw_emburse_transaction: #{raw_emburse_transaction.id}" if raw_emburse_transaction.hashed_transactions.length > 1

          next if raw_emburse_transaction.hashed_transactions.length < 1 # skip. these are raw transactions that haven't yet been hashed for some reason. TODO. surface these somehow elsewhere

          canonical_transaction_id = raw_emburse_transaction.hashed_transactions.first.canonical_transaction.try(:id)

          next unless canonical_transaction_id # TODO: surface why canonical transaction is not set for this hashed transaction

          historical_emburse_transactions = EmburseTransaction.with_deleted.where(emburse_id: raw_emburse_transaction.emburse_transaction_id)
          historical_emburse_transactions = historical_emburse_transactions.select { |het| het.deleted_at.nil? } if historical_emburse_transactions.length > 1

          raise ArgumentError, "There was more than 1 historical non-deleted emburse transaction for raw_emburse_transaction: #{raw_emburse_transaction.id}" if historical_emburse_transactions.length > 1

          historical_emburse_transaction = historical_emburse_transactions.first

          next unless historical_emburse_transaction # TODO: surface this data somewhere. if missing this means historical data is missing in the old transaction system

          event_id = historical_emburse_transaction.event.try(:id)

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

      def deprecated_transaction_emburse_ids
        @deprecated_transaction_emburse_ids ||= EmburseTransaction.with_deleted.pluck(:emburse_id)
      end

      def raw_emburse_transaction_ids
        @raw_emburse_transaction_ids ||= RawEmburseTransaction.where("date_posted >= ?", @start_date).pluck(:emburse_transaction_id)
      end

      def in_common_emburse_transaction_ids
        @in_common_emburse_transaction_ids ||= deprecated_transaction_emburse_ids && raw_emburse_transaction_ids
      end
    end
  end
end
