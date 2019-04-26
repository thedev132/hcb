class FeeReimbursementMailer < ApplicationMailer
  def admin_notification(params)
    @fee_reimbursement = params[:fee_reimbursement]

    mail to: admin_email, subject: 'Fee reimbursement unmatched after 5 days'
  end
end
