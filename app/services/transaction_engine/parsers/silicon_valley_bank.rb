# frozen_string_literal: true

module TransactionEngine
  module Parsers
    class SiliconValleyBank
      def initialize(filepath:)
        @filepath = filepath
      end

      def run
        File.open(@filepath) do |f|
          f.gets # pre-read garbage line

          csv = CSV.new(f, headers: true)

          csv.each do |row|
            insert(row: row)
          end

        end
      end

      private

      def insert(row:)
        return if row["Date"] == "File Totals"

        attrs = {
          unique_bank_identifier: unique_bank_identifier,
          date_posted: row["Date"],
          amount_cents: amount_cents(row),
          memo: row["Description"],
          csv_transaction_id: csv_transaction_id(row)
        }
        RawCsvTransaction.create!(attrs)
      rescue ActiveRecord::RecordNotUnique => e
        # rescue not unique
      end

      def amount_cents(row)
        amount_cents = dollars_to_cents(row["Credit Amount"])
        amount_cents = -dollars_to_cents(row["Debit Amount"]) if row["Debit Amount"]

        amount_cents
      end

      def csv_transaction_id(row)
        "svb_fsmain_#{row["Bank Ref #"]}"
      end

      def unique_bank_identifier
        "FSMAIN"
      end

      def dollars_to_cents(dollars)
        return nil unless dollars.present?

        (100 * dollars.to_r).to_i
      end
    end
  end
end
