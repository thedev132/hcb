class InvoicePayoutsMailer < ApplicationMailer
  def notify_organizers
    @payout = params[:payout]
    @emails = @payout.invoice.sponsor.event.users.map { |u| u.email }

    mail to: @emails, subject: "Payout requested for #{@payout.invoice.sponsor.name} payment"
  end
end
