module CanonicalTransactionService
  module MapToEvent
    class Github
      def initialize(canonical_transaction:)
        @canonical_transaction = canonical_transaction
      end

      def run
        return unless guess_event_id

        attrs = {
          canonical_transaction_id: @canonical_transaction.id,
          event_id: guess_event_id
        }
        ::CanonicalEventMapping.create!(attrs)
      end

      private

      def memo
        @memo ||= @canonical_transaction.memo
      end

      def guess_event_id
        @guess_event_id ||= begin
          return unless likely_events.count == 1

          likely_events.first.id
        end
      end

      def likely_event_name
        /(.*)GitHub Grant.*/.match(memo)[1].strip
      end

      def likely_events
        @likely_events ||= Event.where("name ilike '%#{likely_event_name}%'")
      end
    end
  end
end

