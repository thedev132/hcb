class SendUnmatchedFeeReimbursementEmailJob < ApplicationJob
  def perform(fr)
    FeeReimbursementMailer.admin_notification(fee_reimbursement: fr).deliver_later
  end
end
