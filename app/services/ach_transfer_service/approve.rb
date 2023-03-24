# frozen_string_literal: true

module AchTransferService
  class Approve
    def initialize(ach_transfer_id:, processor:)
      @ach_transfer_id = ach_transfer_id
      @processor = processor
    end

    def run
      ActiveRecord::Base.transaction do
        increase_ach_transfer = Increase::AchTransfers.create(
          account_id: IncreaseService::AccountIds::FS_MAIN,
          account_number: ach_transfer.account_number,
          routing_number: ach_transfer.routing_number,
          amount: ach_transfer.amount,
          statement_descriptor: ach_transfer.payment_for,
          individual_name: ach_transfer.recipient_name[0...22],
          company_name: ach_transfer.event.name[0...16]
        )

        ach_transfer.mark_in_transit!
        ach_transfer.update!(increase_id: increase_ach_transfer["id"], processor: @processor)
      end

      ach_transfer
    end

    private

    def ach_transfer
      @ach_transfer ||= AchTransfer.find(@ach_transfer_id)
    end

  end
end
