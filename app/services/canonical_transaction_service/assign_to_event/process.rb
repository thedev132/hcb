module CanonicalTransactionService
  module AssignToEvent
    class Process
      def run
        likely_githubs.find_each do |ct|

          ::CanonicalTransactionService::AssignToEvent::Github.new(canonical_transaction: ct).run

        end
      end

      private

      def likely_githubs
        ::CanonicalTransaction.exclude(excluded_ids).likely_github
      end

      def excluded_ids
        @excluded_ids ||= ::CanonicalEventMapping.pluck(:canonical_transaction_id)
      end
    end
  end
end
