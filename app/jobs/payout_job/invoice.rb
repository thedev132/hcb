# frozen_string_literal: true

module PayoutJob
  class Invoice < ApplicationJob
    queue_as :default
    def perform(invoice_id)
      ::PayoutService::Invoice::Create.new(invoice_id:).run
    end

  end
end
