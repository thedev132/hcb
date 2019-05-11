module InvoicesHelper
  def invoice_paid_at(invoice = @invoice)
    timestamp = invoice.manually_marked_as_paid_at || invoice&.payout&.created_at
    timestamp ? format_datetime(timestamp) : nil
  end

  def invoice_payment_method(invoice = @invoice)
    if invoice.manually_marked_as_paid?
      return '–'
    elsif invoice&.payout
      return invoice.payout.source_type.humanize
    end
  end

  def invoice_hcb_percent(humanized = true, invoice = @invoice)
    percent = invoice.event.sponsorship_fee
    percent ||= invoice.payout.t_transaction.fee_relationship.fee_percent

    return nil if percent == 0
    return percent unless humanized

    number_to_percentage percent * 100, precision: 0
  end

  def invoice_payment_processor_fee(humanized = true, invoice = @invoice)
    fee = invoice.manually_marked_as_paid? ? 0 : invoice.item_amount - invoice.payout.amount

    return fee unless humanized

    render_money fee
  end

  def invoice_hcb_revenue(humanized = true, invoice = @invoice)
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

  def invoice_hcb_profit(humanized = true, invoice = @invoice)
    profit = invoice_hcb_revenue(false) - invoice_payment_processor_fee(false)

    return profit unless humanized

    render_money profit
  end

  def invoice_event_profit(humanized = true, invoice = @invoice)
    profit = invoice.item_amount * (1 - invoice_hcb_percent(false))

    unless invoice.fee_reimbursed?
      # (max@maxwofford.com) before we reimbursed Stripe fees, event fees were
      # calculated as a percent of the payout
      profit = invoice.item_amount - invoice_payment_processor_fee(false) - invoice_hcb_revenue(false)
    end

    return profit unless humanized

    render_money profit
  end
end
