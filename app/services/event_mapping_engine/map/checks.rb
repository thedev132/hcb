module EventMappingEngine
  module Map
    class Checks
      def run
        likely_clearing_checks.find_each(batch_size: 100) do |ct|
          # 1 locate event id
          guessed_event_id = ::EventMappingEngine::GuessEventId::Check.new(canonical_transaction: ct).run

          next unless guessed_event_id

          ActiveRecord::Base.transaction do
            # 2 locate pair - the pairing item is
            # a. inverse amount
            # b. up to 1 month in the past
            # c. memo contains 'FROM DDA#80007609524'

            paired_canonical_transactions = ::CanonicalTransaction.unmapped.where("memo ilike '%FROM DDA#80007609524 ON%' and amount_cents = ? and date >= ? and date <= ?", -ct.amount_cents, ct.date - 1.month, ct.date)

            Airbrake.notify("There were 2 or more matches when attempting to clear check for canonical transaction #{ct.id}") if paired_canonical_transactions.length > 1
            next if paired_canonical_transactions.length > 1

            paired_canonical_transaction = paired_canonical_transactions.first

            next unless paired_canonical_transaction

            # original
            attrs = {
              canonical_transaction_id: ct.id,
              event_id: guessed_event_id
            }
            ::CanonicalEventMapping.create!(attrs)

            # pair
            attrs = {
              canonical_transaction_id: paired_canonical_transaction.id,
              event_id: guessed_event_id
            }
            ::CanonicalEventMapping.create!(attrs)
          end
        end
      end

      private

      def likely_clearing_checks
        ::CanonicalTransaction.unmapped.likely_clearing_checks
      end

    end
  end
end
