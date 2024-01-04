# frozen_string_literal: true

module ReceiptJob
  class ExtractTextualContent < ApplicationJob
    queue_as :low
    def perform(receipt)
      unless receipt.textual_content.present?
        receipt.extract_textual_content!
      end
    end

  end
end
