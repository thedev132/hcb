module TransactionEngine
  module HashedTransactionService
    class PrimaryHash
      def initialize(date:, amount_cents:, memo:)
        @date = date
        @amount_cents = amount_cents
        @memo = memo.to_s.delete(' ')
      end

      def run
        raise ArgumentError, 'memo must be upcased' unless memo_is_upcased?
        raise ArgumentError, 'amount cents is not an integer' unless amount_cents_is_integer?
        raise ArgumentError, 'amount cents cannot be zero' if amount_cents_is_zero?
        raise ArgumentError, 'date must be formatted correctly' unless date_formatted_correctly?

        [XXhash.xxh64(csv), csv]
      end

      private

      def csv
        @csv ||= CSV.generate(force_quotes: true) { |csv| csv << input_array }
      end

      def input_array
        [
          @date,
          @memo,
          @amount_cents
        ]
      end

      def seed
        0
      end

      def memo_is_upcased?
        @memo.upcase == @memo
      end

      def amount_cents_is_integer?
        @amount_cents.to_i == @amount_cents
      end

      def amount_cents_is_zero?
        @amount_cents == 0
      end

      def date_formatted_correctly?
        Date.parse(@date).strftime('%Y-%m-%d') == @date
      end
    end
  end
end
