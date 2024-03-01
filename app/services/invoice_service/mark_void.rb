# frozen_string_literal: true

module InvoiceService
  class MarkVoid
    def initialize(invoice_id:, user:)
      @invoice_id = invoice_id
      @user = user
    end

    def run
      return if invoice.paid_v2? # return if already marked paid

      Invoice.transaction do
        invoice.voided_by = @user

        invoice.mark_void!
        invoice.close_stripe_invoice

        invoice.save!
      end
    end

    def invoice
      @invoice ||= Invoice.find(@invoice_id)
    end

  end
end
