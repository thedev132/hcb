# frozen_string_literal: true

module AchTransferService
  class Reject
    def initialize(ach_transfer_id:)
      @ach_transfer_id = ach_transfer_id
    end

    def run
      ActiveRecord::Base.transaction do
        ach_transfer.mark_rejected!
      end

      ach_transfer
    end

    private

    def ach_transfer
      @ach_transfer ||= AchTransfer.find(@ach_transfer_id)
    end
  end
end
