# frozen_string_literal: true

class CanonicalPendingTransactionMailer < ApplicationMailer
  def notify_approved
    @cpt = CanonicalPendingTransaction.find(params[:canonical_pending_transaction_id])
    @user = @cpt.stripe_card.user
    @receipt_upload_feature = Flipper.enabled?(:receipt_email_upload_2022_05_10, @cpt.stripe_card.user)
    @upload_url = HcbCodeService::Receipt::SigningEndpoint.new.create(@cpt.local_hcb_code)

    to = @cpt.stripe_card.user.email
    subject = "Upload a receipt for your transaction at #{@cpt.smart_memo}"
    reply_to = if @receipt_upload_feature
                 HcbCode.find_or_create_by(hcb_code: @cpt.hcb_code).receipt_upload_email
               else
                 to
               end

    mail to: to, subject: subject, reply_to: reply_to
  end

end
