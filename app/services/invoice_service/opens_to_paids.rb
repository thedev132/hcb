# frozen_string_literal: true

module InvoiceService
  class OpensToPaids
    def initialize(since_date: nil)
      @since_date = Time.now.utc - 6.months # only look back last 6 months
    end

    def run
      # 1. iterate over open invoices
      Invoice.open.where("created_at >= ?", @since_date).each do |i|

        ActiveRecord::Base.connection do
          i.sync_from_remote!

          if i.reload.paid?
            raise NoAssociatedStripeCharge if i.remote_invoice.charge.nil?

            b_tnx = i.charge.balance_transaction

            funds_available_at = Util.unixtime(b_tnx.available_on)
            create_payout_at = funds_available_at + 1.day

            i.payout_creation_queued_at = Time.current
            i.payout_creation_queued_for = create_payout_at
            i.payout_creation_balance_net = b_tnx.net - hidden_fee(i.remote_invoice) # amount to pay out
            i.payout_creation_balance_stripe_fee = b_tnx.fee + hidden_fee(i.remote_invoice)
            i.payout_creation_balance_available_at = funds_available_at

            i.save!
          end
        end

      end
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
