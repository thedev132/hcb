module EventMappingEngine
  module Map
    class HistoricalEmburse
      def run
        RawEmburseTransaction.where(emburse_transaction_id: in_common_emburse_transaction_ids).find_each do |raw_emburse_transaction|

          raise ArgumentError, 'There was not 1 hashed transaction relationship' unless raw_emburse_transaction.hashed_transactions.length == 1 # use length here rather than count

          canonical_transaction_id = raw_emburse_transaction.hashed_transactions.first.canonical_transaction.id

          historical_emburse_transaction = EmburseTransaction.with_deleted.find_by(emburse_id: raw_emburse_transaction.emburse_transaction_id)

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
        rescue => e
          byebug

          raise e
        end
      end

      private

      def deprecated_transaction_emburse_ids
        @deprecated_transaction_emburse_ids ||= EmburseTransaction.with_deleted.pluck(:emburse_id)
      end

      def raw_emburse_transaction_ids
        @raw_emburse_transaction_ids ||= RawEmburseTransaction.pluck(:emburse_transaction_id)
      end

      def in_common_emburse_transaction_ids
        @in_common_emburse_transaction_ids ||= deprecated_transaction_emburse_ids && raw_emburse_transaction_ids
      end
    end
  end
end
