# frozen_string_literal: true

module InvoiceJob
  class Nightly < ApplicationJob
    def perform
      ::InvoiceService::Nightly.new.run
    end
  end
end
