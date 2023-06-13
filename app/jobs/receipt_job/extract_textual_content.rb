# frozen_string_literal: true

module ReceiptJob
  class ExtractTextualContent < ApplicationJob
    def perform(receipt)
      receipt.extract_textual_content!
    end

  end
end
