class EmburseTransactionsMailer < ApplicationMailer
  def notify(params)
    @emburse_transaction = params[:emburse_transaction]

    mail to: admin_email,
      subject: "[Action Requested] No department linked to Emburse transaction ##{@emburse_transaction.id}"
  end
end
