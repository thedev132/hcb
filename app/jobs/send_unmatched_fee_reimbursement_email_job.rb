# frozen_string_literal: true

class SendUnmatchedFeeReimbursementEmailJob < ApplicationJob
  def perform(fr)
    # if it's been matched, this job no longer needs to happen
    return if fr.completed?

    FeeReimbursementMailer.with(fee_reimbursement: fr).admin_notification.deliver_later
  end
end
