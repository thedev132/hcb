# frozen_string_literal: true

module InvoiceService
  class SyncRemoteToLocal
    def initialize(invoice_id:)
      @invoice_id = invoice_id
    end

    def run
      invoice.amount_due = remote_invoice.amount_due
      invoice.amount_paid = remote_invoice.amount_paid
      invoice.amount_remaining = remote_invoice.amount_remaining
      invoice.attempt_count = remote_invoice.attempt_count
      invoice.attempted = remote_invoice.attempted
      invoice.auto_advance = remote_invoice.auto_advance
      invoice.due_date = Time.at(remote_invoice.due_date).to_datetime # convert from unixtime
      invoice.ending_balance = remote_invoice.ending_balance
      invoice.finalized_at = remote_invoice.finalized_at
      invoice.hosted_invoice_url = remote_invoice.hosted_invoice_url
      invoice.invoice_pdf = remote_invoice.invoice_pdf
      invoice.livemode = remote_invoice.livemode
      invoice.memo = remote_invoice.description
      invoice.number = remote_invoice.number
      invoice.starting_balance = remote_invoice.starting_balance
      invoice.statement_descriptor = remote_invoice.statement_descriptor
      invoice.status = remote_invoice.status
      invoice.stripe_charge_id = remote_invoice&.charge&.id
      invoice.subtotal = remote_invoice.subtotal
      invoice.tax = remote_invoice.tax
      invoice.tax_percent = remote_invoice.tax_percent
      invoice.total = remote_invoice.total
      # https://stripe.com/docs/api/charges/object#charge_object-payment_method_details
      invoice.payment_method_type = type = remote_invoice&.charge&.payment_method_details&.type
      if invoice.payment_method_type
        details = remote_invoice&.charge&.payment_method_details[invoice.payment_method_type]
        if details
          if type == "card"
            invoice.payment_method_card_brand = details.brand
            invoice.payment_method_card_checks_address_line1_check = details.checks.address_line1_check
            invoice.payment_method_card_checks_address_postal_code_check = details.checks.address_postal_code_check
            invoice.payment_method_card_checks_cvc_check = details.checks.cvc_check
            invoice.payment_method_card_country = details.country
            invoice.payment_method_card_exp_month = details.exp_month
            invoice.payment_method_card_exp_year = details.exp_year
            invoice.payment_method_card_funding = details.funding
            invoice.payment_method_card_last4 = details.last4
          elsif type == "ach_credit_transfer"
            invoice.payment_method_ach_credit_transfer_bank_name = details.bank_name
            invoice.payment_method_ach_credit_transfer_routing_number = details.routing_number
            invoice.payment_method_ach_credit_transfer_account_number = details.account_number
            invoice.payment_method_ach_credit_transfer_swift_code = details.swift_code
          end
        end
      end

      invoice.save!
    end

    private

    def invoice
      @invoice ||= Invoice.find(@invoice_id)
    end

    def remote_invoice
      @remote_invoice ||= invoice.remote_invoice
    end
  end
end
