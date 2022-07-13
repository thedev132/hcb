# frozen_string_literal: true

module OneTimeJobs
  class SetAchTransferAmountJob < ApplicationJob
    def perform(ach_id: 1040, updated_amount: 652600)
      ach = AchTransfer.find ach_id

      hcb = ach.local_hcb_code
      pt = hcb.pt
      rpoat = pt.raw_pending_outgoing_ach_transaction

      ActiveRecord::Base.transaction do
        ach.amount = updated_amount
        ach.save!

        rpoat.amount_cents = -updated_amount
        rpoat.save!

        pt.amount_cents = -updated_amount
        pt.save!
      end
    end

  end
end
