# frozen_string_literal: true

class InvoicePayoutsMailer < ApplicationMailer
  def notify_organizers
    @payout = params[:payout]
    @emails = @payout.invoice.sponsor.event.users.map { |u| u.email }

    mail to: @emails, subject: "Payment from #{@payout.invoice.sponsor.name} is on the way 💵"
  end
end
