module EventMappingEngine
  module Map
    class Historical
      def run
        likely_historicals.find_each do |ct|
          raw_plaid_ids = ct.hashed_transactions.pluck(:raw_plaid).compact

          historical_transactions = raw_plaid_ids.map do |rpid|
            Transaction.find_by(plaid_id: rpid)
          end

          return unless historical_transactions.size == 1

          guessed_event_id = historical_transactions.first&.event&.id

          return unless guessed_event_id

          attrs = {
            canonical_transaction_id: ct.id
            event_id: guessed_event_id
          }
          ::CanonicalEventMapping.create!(attrs)
        end
      end

      private

      def likely_historicals
        ::CanonicalTransaction.awaiting_match.where('created_at <= ?', last_historical_transaction_date)
      end

      def last_historical_transaction_date
        Transaction.order('date DESC').first.date
      end
    end
  end
end
