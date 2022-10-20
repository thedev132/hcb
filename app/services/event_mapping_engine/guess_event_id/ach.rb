# frozen_string_literal: true

module EventMappingEngine
  module GuessEventId
    class Ach
      def initialize(canonical_transaction:)
        @canonical_transaction = canonical_transaction
      end

      def run
        ach.try(:event).try(:id)
      end

      private

      def ach
        confirmation_number = @canonical_transaction.likely_ach_confirmation_number

        return nil unless confirmation_number

        @ach ||= AchTransfer.find_by(confirmation_number: confirmation_number)
      end

    end
  end
end
