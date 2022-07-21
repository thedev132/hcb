# frozen_string_literal: true

class InvoiceMailerPreview < ActionMailer::Preview
  def notify_organizers
    @invoice = Invoice.last
    InvoiceMailer.with(invoice: @invoice).notify_organizers
  end

end
