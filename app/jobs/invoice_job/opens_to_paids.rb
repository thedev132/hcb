# frozen_string_literal: true

module InvoiceJob
  class OpensToPaids < ApplicationJob
    queue_as :low
    def perform
      ::InvoiceService::OpensToPaids.new.run
    end

  end
end
