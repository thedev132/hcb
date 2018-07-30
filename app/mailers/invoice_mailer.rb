class InvoiceMailer < ApplicationMailer
  def payment_notification
    @invoice = params[:invoice]
    @emails = @invoice.sponsor.event.users.map { |u| u.email }

    mail to: @emails, subject: "Invoice to #{@invoice.sponsor.name} paid"
  end
end
