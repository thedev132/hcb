# frozen_string_literal: true

module InvoiceJob
  class OpensToPaids < ApplicationJob
    def perform
      ::InvoiceService::OpensToPaids.new.run
    end
  end
end
