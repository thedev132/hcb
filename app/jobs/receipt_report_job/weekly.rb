# frozen_string_literal: true

module ReceiptReportJob
  class Weekly < ApplicationJob
    def perform
      User.find_each(batch_size: 100) do |user|
        Send.perform_later(user.id)
      end
    end

  end
end
