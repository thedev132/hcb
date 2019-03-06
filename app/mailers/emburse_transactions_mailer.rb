class EmburseTransactionsMailer < ApplicationMailer
  def notify(params)
    @emburse_transaction = params[:emburse_transaction]

    mail to: admin_email,
      subject: "[Action Requested] No department linked to Emburse transaction ##{@emburse_transaction.id}"
  end

  def organizer_notify(params)
    @event = params[:event]
    @emburse_transaction = params[:emburse_transaction]

    emails = @event.users.map { |u| u.email }
    mail to: emails,
      subject: "$#{BigDecimal.new(@emburse_transaction.amount.abs)/100} spent at #{@emburse_transaction.merchant_name} by #{@emburse_transaction.card.user.name}"
  end
end
