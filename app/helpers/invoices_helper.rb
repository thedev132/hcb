module InvoicesHelper
  def invoice_paid_at(invoice = @invoice)
    timestamp = invoice.manually_marked_as_paid_at || invoice&.payout&.created_at
    timestamp ? format_datetime(timestamp) : nil
  end

  def invoice_hcb_percent(invoice = @invoice, humanized = true)
    percent = invoice.event.sponsorship_fee
    percent ||= invoice.payout.t_transaction.fee_relationship.fee_percent

    return nil if percent == 0
    return percent unless humanized

    number_to_percentage percent * 100, precision: 0
  end

  def invoice_payment_processor_fee(invoice = @invoice, humanized = true)
    fee = invoice.manually_marked_as_paid? ? 0 : invoice.item_amount - invoice.payout.amount

    return fee unless humanized

    render_money fee
  end

  def invoice_hcb_revenue(invoice = @invoice, humanized = true)
    fee = invoice.payout.t_transaction.fee_relationship.fee_percent
    revenue = fee.present? ? invoice.item_amount * fee : 0

    unless invoice.fee_reimbursed?
      # (max@maxwofford.com) before we reimbursed Stripe fees, we calculated
      # our fee from the invoice payout amount *after* Stripe fees were
      # deducted
      revenue = invoice.payout.t_transaction.fee_relationship.fee_amount
    end

    return revenue unless humanized

    render_money revenue
  end

  def invoice_hcb_profit(invoice = @invoice, humanized = true)
    profit = invoice_hcb_revenue(invoice, false) - invoice_payment_processor_fee(invoice, false)

    return profit unless humanized

    render_money profit
  end

  def invoice_event_profit(invoice = @invoice, humanized = true)
    profit = invoice.item_amount * (1 - invoice_hcb_percent(invoice, false))

    unless invoice.fee_reimbursed?
      # (max@maxwofford.com) before we reimbursed Stripe fees, event fees were
      # calculated as a percent of the payout
      profit = invoice.item_amount - invoice_payment_processor_fee(invoice, false) - invoice_hcb_revenue(invoice, false)
    end

    return profit unless humanized

    render_money profit
  end
end
