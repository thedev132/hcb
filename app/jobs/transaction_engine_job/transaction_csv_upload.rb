# frozen_string_literal: true

module TransactionEngineJob
  class TransactionCsvUpload < ApplicationJob
    queue_as :default
    def perform(transaction_csv_id)
      ::TransactionEngine::TransactionCsvService::Upload.new(transaction_csv_id:).run
    end

  end
end
