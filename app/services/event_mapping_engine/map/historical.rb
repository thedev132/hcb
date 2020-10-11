module EventMappingEngine
  module Map
    class Historical
      def run
        likely_historicals.find_each do |ct|
          historical_transactions = Transaction.where(
            amount: ct.amount_cents,
            name: ct.memo,
            date: ct.date
          )

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
        ::CanonicalTransaction.where('created_at <= ?', last_historical_transaction_date)
      end

      def last_historical_transaction_date
        Transaction.order('date DESC').first.date
      end
    end
  end
end
