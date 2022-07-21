# frozen_string_literal: true

class InvoicePayoutsMailer < ApplicationMailer
  def notify_organizers
    @payout = params[:payout]
    @emails = @payout.invoice.sponsor.event.users.map { |u| u.email }

    if @payout.invoice.sponsor.event.can_front_balance?
      mail to: @emails, subject: "Payment from #{@payout.invoice.sponsor.name} has arrived 💵"
    else
      mail to: @emails, subject: "Payment from #{@payout.invoice.sponsor.name} is on the way 💵"
    end

  end

end
