class FeeReimbursementMailerPreview < ActionMailer::Preview
  def admin_notification
    config = {
      fee_reimbursement: FeeReimbursement.last
    }
    FeeReimbursementMailer.with(config).send __method__
  end
end