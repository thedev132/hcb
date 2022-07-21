# frozen_string_literal: true

class InvoiceMailer < ApplicationMailer
  def notify_organizers
    @invoice = params[:invoice]
    @emails = @invoice.sponsor.event.users.map { |u| u.email }

    if @invoice.sponsor.event.can_front_balance?
      mail to: @emails, subject: "Payment from #{@invoice.sponsor.name} has arrived 💵"
    else
      mail to: @emails, subject: "Payment from #{@invoice.sponsor.name} is on the way 💵"
    end

  end

end
