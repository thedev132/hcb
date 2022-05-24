# frozen_string_literal: true

class InvoiceMailerPreview < ActionMailer::Preview
  def payment_notification
    @invoice = Invoice.paid_v2.last
    InvoiceMailer.with(invoice: @invoice).payment_notification
  end

  def first_payment_notification
    @invoice = Invoice.paid_v2.last
    InvoiceMailer.with(invoice: @invoice).first_payment_notification
  end

end
