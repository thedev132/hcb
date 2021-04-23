# frozen_string_literal: true

module RawCsvTransactionService
  class Create
    def initialize(unique_bank_identifier:, date:, memo:, amount:)
      @unique_bank_identifier = unique_bank_identifier
      @date = date
      @memo = memo
      @amount = amount
    end

    def run
      ::RawCsvTransaction.create!(attrs)
    end

    private

    def attrs
      {
        unique_bank_identifier: @unique_bank_identifier,
        date_posted: date_posted,
        memo: @memo,
        amount: @amount,
        csv_transaction_id: generate_unique_csv_transaction_id,
        raw_data: []
      }
    end

    def date_posted
      Chronic.parse(@date)
    end

    def generate_unique_csv_transaction_id
      "manual_#{SecureRandom.hex}"
    end
  end
end
