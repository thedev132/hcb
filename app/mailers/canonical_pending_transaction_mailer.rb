# frozen_string_literal: true

class CanonicalPendingTransactionMailer < ApplicationMailer
  def notify_approved
    @cpt = CanonicalPendingTransaction.find(params[:canonical_pending_transaction_id])

    to = @cpt.stripe_card.user.email
    subject = "Upload a receipt for your transaction at #{@cpt.smart_memo}"

    mail to: to, subject: subject
  end

end
