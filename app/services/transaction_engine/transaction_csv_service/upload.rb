# frozen_string_literal: true

module TransactionEngine
  module TransactionCsvService
    class Upload
      def initialize(transaction_csv_id:)
        @transaction_csv_id = transaction_csv_id
      end

      def run
        transaction_csv.mark_processing!

        transaction_csv.file.open do |f|
          ::TransactionEngine::Parsers::SiliconValleyBank.new(filepath: f.path).run
        end

        transaction_csv.mark_processed!
      end

      private

      def transaction_csv
        @transaction_csv ||= ::TransactionCsv.find(@transaction_csv_id)
      end
    end
  end
end
