# frozen_string_literal: true

module InvoiceService
  class Queue
    def initialize(invoice_id:)
      @invoice_id = invoice_id
    end

    def run
      raise NoAssociatedStripeCharge if remote_invoice.charge.nil?

      b_tnx = remote_invoice.charge.balance_transaction

      funds_available_at = Util.unixtime(b_tnx.available_on)
      create_payout_at = funds_available_at + 1.day

      invoice.payout_creation_queued_at = Time.current
      invoice.payout_creation_queued_for = create_payout_at
      invoice.payout_creation_balance_net = b_tnx.net - hidden_fee(remote_invoice) # amount to pay out
      invoice.payout_creation_balance_stripe_fee = b_tnx.fee + hidden_fee(remote_invoice)
      invoice.payout_creation_balance_available_at = funds_available_at

      invoice.save!
    end

    private

    def invoice
      @invoice ||= Invoice.find(@invoice_id)
    end

    def remote_invoice
      @remote_invoice ||= ::Partners::Stripe::Invoices::Show.new(id: invoice.stripe_invoice_id).run
    end

    def hidden_fee(inv)
      # stripe has hidden fees for ACH Credit TXs that don't show in the API at the moment:
      # https://support.stripe.com/questions/pricing-of-payment-methods-in-the-us
      c = inv.charge
      if c.payment_method_details.type != "ach_credit_transfer"
        return 0
      end

      if c.amount < 1000 * 100
        return 700
      elsif c.amount < 100000 * 100
        return 1450
      else
        return 2450
      end
    end
  end
end
