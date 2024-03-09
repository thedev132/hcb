# frozen_string_literal: true

class InvoiceMailerPreview < ActionMailer::Preview
  def notify_organizers_sent
    @invoice = Invoice.last
    InvoiceMailer.with(invoice: @invoice).notify_organizers_sent
  end

  def notify_organizers_paid
    @invoice = Invoice.last
    InvoiceMailer.with(invoice: @invoice).notify_organizers_paid
  end

end
