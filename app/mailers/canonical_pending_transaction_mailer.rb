class CanonicalPendingTransactionMailer < ApplicationMailer
  def notify_bank_alerts
    @cpt = CanonicalPendingTransaction.find(params[:canonical_pending_transaction_id])

    to = "bank-alerts@hackclub.com"
    subject = "CanonicalPendingTransaction: #{@cpt.hcb_code} (#{@cpt.event.name})"

    mail to: to, subject: subject
  end

  def notify_approved
    @cpt = CanonicalPendingTransaction.find(params[:canonical_pending_transaction_id])

    to = @cpt.stripe_card.user.email
    subject = "Upload a receipt for your transaction at #{@cpt.smart_memo}"

    mail to: to, subject: subject
  end
end
