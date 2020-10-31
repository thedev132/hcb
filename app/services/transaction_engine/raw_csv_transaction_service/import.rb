require 'csv'
require 'open-uri'

module TransactionEngine
  module RawCsvTransactionService
    class Import
      def run
        read_and_parse_frb
        read_and_parse_svb
      end

      private

      def read_and_parse_frb
        ActiveRecord::Base.transaction do
          csv_text = open('https://gist.githubusercontent.com/maxwofford/ab0e5fd29cf2dad02c56444029b38abd/raw/a2434362ef2c3ea1605d61bf74130d75b0fe58a9/IRE1015202009343020704689603593.CSV')
          csv_data = CSV.parse(csv_text, headers: true)
          csv_data.each_with_index do |row, index|
            next unless row.present? # skip empty rows

            raise ArgumentError, "amount_cents is required for row #{index}" unless row['Amount']
            raise ArgumentError, "date is required for row #{index}" unless row['Date']
            raise ArgumentError, "memo is required for row #{index}" unless row['Description']

            attrs = {
              amount_cents: row['Amount'],
              date_posted: row['Date'],
              memo: row['Description'],
              raw_data: row,
            }

            RawCsvTransaction.create!(attrs)
          end
        end
      end

      def read_and_parse_svb
        ActiveRecord::Base.transaction do
          csv_text = open('https://gist.githubusercontent.com/maxwofford/2ededb56799bd961e02fbe9613f08941/raw/f28bdff047aa69d25205da83431038164bfdb012/DDATransactions_1146778122101285346462810_10152020093705.csv')
          csv_data = CSV.parse(csv_text, headers: true)
          csv_data.each_with_index do |row, index|
            next unless row.present? # skip empty rows

            raise ArgumentError, "amount_cents is required for row #{index}" unless row['Amount']
            raise ArgumentError, "date is required for row #{index}" unless row['Transaction Date']
            raise ArgumentError, "memo is required for row #{index}" unless row['Text']

            attrs = {
              amount_cents: (row['Amount'] * 100).to_i,
              date_posted: row['Transaction Date'],
              memo: row['Text'],
              raw_data: row,
            }

            RawCsvTransaction.create!(attrs)
          end
        end
      end
    end
  end
end
