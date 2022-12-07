# frozen_string_literal: true

module AchTransferService
  class Approve
    def initialize(ach_transfer_id:, scheduled_arrival_date:, confirmation_number:, processor:)
      @ach_transfer_id = ach_transfer_id
      @scheduled_arrival_date = scheduled_arrival_date
      @confirmation_number = confirmation_number
      @processor = processor
    end

    def run
      raise ArgumentError, "scheduled_arrival_date is required" unless @scheduled_arrival_date.present?
      raise ArgumentError, "confirmation_number is required" unless @confirmation_number.present?

      ActiveRecord::Base.transaction do
        ach_transfer.mark_in_transit!

        ach_transfer.update!(
          processor: @processor,
          scheduled_arrival_date: chronic_scheduled_arrival_date,
          confirmation_number: @confirmation_number
        )
      end

      ach_transfer
    end

    private

    def chronic_scheduled_arrival_date
      @chronic_scheduled_arrival_date ||= Chronic.parse(@scheduled_arrival_date)
    end

    def ach_transfer
      @ach_transfer ||= AchTransfer.find(@ach_transfer_id)
    end

  end
end
