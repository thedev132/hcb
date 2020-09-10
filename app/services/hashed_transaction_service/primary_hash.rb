module HashedTransactionService
  class PrimaryHash
    def initialize(date:, amount_cents:, memo:)
      @date = date
      @amount_cents = amount_cents
      @memo = memo
    end

    def run
      raise ArgumentError unless memo_is_upcased?
      raise ArgumentError unless amount_cents_is_integer?
      raise ArgumentError if amount_cents_is_zero?
      raise ArgumentError if memo_is_empty?
      raise ArgumentError unless date_formatted_correctly?

      XXhash.xxh64(csv)
    end

    private

    def input
      "#{@date} |  / #{@memo.upcase} / #{@amount_cents} / #{}"
    end

    def csv
      CSV.generate(force_quotes: true) { |csv| csv << input_array }
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

    def memo_is_empty?
      @memo.blank?
    end

    def date_formatted_correctly?
      Date.parse(@date).strftime('%Y-%m-%d') == @date
    end
  end
end
