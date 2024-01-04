# frozen_string_literal: true

module InvoiceJob
  class OpenToPaid < ApplicationJob
    queue_as :low
    def perform(invoice_id)
      ::InvoiceService::OpenToPaid.new(invoice_id:).run
    end

  end
end
