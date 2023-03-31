# frozen_string_literal: true

module EventMappingEngine
  module Map
    class IncreaseChecks
      def run
        likely_increase_checks.find_each(batch_size: 100) do |ct|
          increase_check = ct.increase_check
          next unless increase_check

          ::CanonicalEventMapping.create!(canonical_transaction: ct, event: increase_check.event)
        end
      end

      private

      def likely_increase_checks
        ::CanonicalTransaction.unmapped.likely_increase_checks.order("date asc")
      end

    end
  end
end
