class EmburseTransactionsMailer < ApplicationMailer
  def notify(params)
    @recipient = 'team@hackclub.com'
    @emburse_transaction_path = params[:emburse_transaction].emburse_path

    mail to: @recipient,
      subject: "[Action Requested] Triage unassociated Emburse transaction"
  end
end
