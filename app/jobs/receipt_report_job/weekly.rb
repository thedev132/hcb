# frozen_string_literal: true

module ReceiptReportJob
  class Weekly < ApplicationJob
    queue_as :low
    def perform
      User.receipt_report_weekly.find_each(batch_size: 100) do |user|
        Send.perform_later(user.id)
      end
    end

  end
end
