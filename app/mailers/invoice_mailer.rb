# frozen_string_literal: true

class InvoiceMailer < ApplicationMailer
  def payment_notification
    @invoice = params[:invoice]
    @emails = @invoice.sponsor.event.users.map { |u| u.email }

    mail to: @emails, subject: "Your invoice to #{@invoice.sponsor.name} was paid ✅"
  end

  def first_payment_notification
    @invoice = params[:invoice]
    @emails = @invoice.sponsor.event.users.map { |u| u.email }

    mail to: @emails, subject: "Congrats! 🎉 Your invoice to #{@invoice.sponsor.name} was paid"
  end
end
