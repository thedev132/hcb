# frozen_string_literal: true

module EventMappingEngine
  module Map
    class ClearingChecks
      def run
        likely_clearing_checks.find_each(batch_size: 100) do |ct|
          # 1 locate event id
          guessed_event_id = ::EventMappingEngine::GuessEventId::ClearingCheck.new(canonical_transaction: ct).run

          next unless guessed_event_id

          ActiveRecord::Base.transaction do
            # 2 locate pair - the pairing item is
            # a. inverse amount
            # b. up to 1 month in the past
            # c. memo contains 'FROM DDA#80007609524'

            paired_canonical_transactions = ::CanonicalTransaction.unmapped.where("memo ilike '%FROM DDA#80007609524 ON%' and amount_cents = ? and date <= ?", -ct.amount_cents, ct.date).order("date asc")
            paired_canonical_transaction = paired_canonical_transactions.first # make use of oldest match first

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
        ::CanonicalTransaction.unmapped.likely_clearing_checks.order("date asc")
      end

    end
  end
end
