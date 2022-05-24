# frozen_string_literal: true

class InvoicePayoutsMailerPreview < ActionMailer::Preview
  def notify_organizers
    @payout = InvoicePayout.last || DonationPayout.last
    InvoicePayoutsMailer.with(payout: @payout).notify_organizers
  end

end
