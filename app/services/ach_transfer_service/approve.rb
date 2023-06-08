# frozen_string_literal: true

module AchTransferService
  class Approve
    def initialize(ach_transfer_id:, processor:)
      @ach_transfer_id = ach_transfer_id
      @processor = processor
    end

    def run
      if ach_transfer.scheduled_on.present?
        ach_transfer.mark_scheduled!
      else
        ach_transfer.send_ach_transfer!
      end

      ach_transfer.update(processor: @processor)

      ach_transfer
    end

    private

    def ach_transfer
      @ach_transfer ||= AchTransfer.find(@ach_transfer_id)
    end

  end
end
