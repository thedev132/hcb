# frozen_string_literal: true

class FeeReimbursementMailer < ApplicationMailer
  def admin_notification
    @fee_reimbursement = params[:fee_reimbursement]

    mail to: admin_email, subject: "Fee refund unmatched after 5 days"
  end
end
