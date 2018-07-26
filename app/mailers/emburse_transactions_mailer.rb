class EmburseTransactionsMailer < ApplicationMailer
  def notify(params)
    @recipient = 'team@hackclub.com'
    @emburse_transaction = params[:emburse_transaction]

    mail to: @recipient,
      subject: "[Action Requested] Triage unassociated Emburse transaction ##{@emburse_transaction.id}"
  end
end
