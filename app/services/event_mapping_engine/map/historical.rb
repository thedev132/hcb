module EventMappingEngine
  module Map
    class Historical
      def run
        unmapped.find_each do |ct|
          raise ArgumentError unless ct.hashed_transactions.count == 1

          raw_plaid_transaction = ct.hashed_transactions.first.raw_plaid_transaction
          next unless raw_plaid_transaction # TODO: support stripe and emburse as well historically

          historical_transaction = Transaction.find_by(plaid_id: raw_plaid_transaction.plaid_transaction_id)
          return unless historical_transaction

          guessed_event_id = historical_transaction.event&.id
          return unless guessed_event_id

          attrs = {
            canonical_transaction_id: ct.id,
            event_id: guessed_event_id
          }
          ::CanonicalEventMapping.create!(attrs)
        end
      end

      def run
      end

      private

      def unmapped
        ::CanonicalTransaction.unmapped
      end

      def deprecated_transaction_plaid_ids
        @deprecated_transaction_plaid_ids ||= Transaction.with_deleted.pluck(:plaid_id)
      end

      def raw_plaid_transaction_ids
        @raw_plaid_transaction_ids ||= RawPlaidTransaction.pluck(:plaid_transaction_id)
      end

      def shared_plaid_transaction_ids
        @shared_plaid_transaction_ids ||= deprecated_transaction_plaid_ids && raw_plaid_transaction_ids
      end
    end
  end
end
