# frozen_string_literal: true

module OneTimeJobs
  class SetReceiptReportOption < ApplicationJob
    def perform
      User.find_each(batch_size: 100) do |user|
        next unless Flipper.enabled?(:receipt_report_2023_04_19, user)

        user.update!(receipt_report_option: :weekly)
      end
    end

  end
end
