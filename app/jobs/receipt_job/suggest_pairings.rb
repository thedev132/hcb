# frozen_string_literal: true

module ReceiptJob
  class SuggestPairings < ApplicationJob
    queue_as :low
    def perform(receipt)
      ::ReceiptService::Suggest.new(receipt:).run!
    end

  end
end
