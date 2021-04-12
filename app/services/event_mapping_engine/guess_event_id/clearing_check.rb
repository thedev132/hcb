module EventMappingEngine
  module GuessEventId
    class ClearingCheck
      def initialize(canonical_transaction:)
        @canonical_transaction = canonical_transaction
      end

      def run
        check.event.id
      end

      private

      def check
        @check ||= ::Check.find_by(check_number: check_number)
      end

      def memo
        @memo ||= @canonical_transaction.memo
      end

      def check_number
        @check_number ||= memo.upcase.gsub("WITHDRAWAL - INCLEARING CHECK #", "")
                                      .gsub("WITHDRAWAL - ON-US DEPOSITED ITE #", "")
      end
    end
  end
end
