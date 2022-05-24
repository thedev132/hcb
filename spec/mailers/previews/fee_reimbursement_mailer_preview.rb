# frozen_string_literal: true

class FeeReimbursementMailerPreview < ActionMailer::Preview
  def admin_notification
    @fee_reimbursement = FeeReimbursement.last
    FeeReimbursementMailer.with(fee_reimbursement: @fee_reimbursement).admin_notification
  end

end
