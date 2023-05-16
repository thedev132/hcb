# frozen_string_literal: true

module ReceiptReportJob
  class Monthly < ApplicationJob
    def perform
      User.receipt_report_monthly.find_each(batch_size: 100) do |user|
        Send.perform_later(user.id)
      end
    end

  end
end
