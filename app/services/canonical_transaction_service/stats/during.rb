module CanonicalTransactionService
  module Stats
    class During
      def initialize(start_time: Date.parse('2015-01-01'), end_time: Date.today)
        @start_time = start_time
        @end_time = end_time
      end

      def run
        tx.sum('amount_cents')
        # tx.size
      end

      private

      def tx
        CanonicalTransaction.included_in_stats
                            .where(date: @start_time..@end_time)
      end
    end
  end
end