class InvoicePayoutsMailer < ApplicationMailer
  def notify_organizers
    @payout = params[:payout]
    @emails = @payout.invoice.sponsor.event.users.map { |u| u.email }

    mail to: @emails, subject: "Payout requested for payment from #{@payout.invoice.sponsor.name}"
  end
end
