# frozen_string_literal: true

module InvoiceService
  class MarkPaid
    def initialize(invoice_id:,
                   reason:, attachment: nil,
                   user:)
      @invoice_id = invoice_id
      @reason = reason
      @attachment = attachment
      @user = user
    end

    def run
      raise ArgumentError, "reason is required" if @reason.blank?

      ActiveRecord::Base.transaction do
        invoice.manually_marked_as_paid_at = Time.current
        invoice.manually_marked_as_paid_user = @user
        invoice.manually_marked_as_paid_reason = @reason
        invoice.manually_marked_as_paid_attachment = @attachment
        invoice.save!
        invoice.mark_paid! # aasm

        remote_invoice.paid = true
        remote_invoice.save
      end

      invoice.set_fields_from_stripe_invoice(remote_invoice)
      invoice.save!
    end

    private

    def invoice
      @invoice ||= Invoice.find(@invoice_id)
    end

    def remote_invoice
      @remote_invoice ||= ::Partners::Stripe::Invoices::Show.new(id: invoice.stripe_invoice_id).run
    end
  end
end
