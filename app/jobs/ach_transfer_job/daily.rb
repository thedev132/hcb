# frozen_string_literal: true

module AchTransferJob
  class Daily < ApplicationJob
    def perform
      AchTransfer.scheduled_for_today.includes(:event).each do |ach_transfer|
        ach_transfer.send_ach_transfer!
      end
    end

  end
end
