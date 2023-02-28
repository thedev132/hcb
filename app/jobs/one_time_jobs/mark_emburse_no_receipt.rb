# frozen_string_literal: true

# This one-time-job is used to mark emburse transactions as no receipt before
# https://github.com/hackclub/bank/pull/3542 is merged in
module OneTimeJobs
  class MarkEmburseNoReceipt < ApplicationJob
    def perform
      EmburseCard.all.each do |card|
        hcb_code_ids = card.hcb_codes.pluck(:id)
        hcb_codes_missing_receipts = HcbCode.where(id: hcb_code_ids).missing_receipt
        hcb_codes_missing_receipts.each do |hcb_code|
          hcb_code.no_or_lost_receipt!
        end
      end
    end

  end
end
