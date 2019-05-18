class SendUnmatchedFeeReimbursementEmailJob < ApplicationJob
  def perform(fr)
    # if it's been matched, this job no longer needs to happen
    return if fr.completed?

    FeeReimbursementMailer.admin_notification(fee_reimbursement: fr).deliver_later
  end
end
