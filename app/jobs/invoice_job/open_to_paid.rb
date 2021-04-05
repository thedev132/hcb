# frozen_string_literal: true

module InvoiceJob
  class OpenToPaid < ApplicationJob
    def perform(invoice_id)
      ::InvoiceService::OpenToPaid.new(invoice_id: invoice_id).run
    end
  end
end
