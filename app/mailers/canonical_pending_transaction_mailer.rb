class CanonicalPendingTransactionMailer < ApplicationMailer
  def notify_bank_alerts
    @cpt = CanonicalPendingTransaction.find(params[:canonical_pending_transaction_id])

    to = "bank-alerts@hackclub.com"
    subject = "CanonicalPendingTransaction: #{@cpt.hcb_code} (#{@cpt.event.name})"

    mail to: to, subject: subject
  end
end
