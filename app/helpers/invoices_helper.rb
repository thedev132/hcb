module InvoicesHelper
  def invoice_hcb_percent(invoice = @invoice, humanized = true)
    percent = invoice.payout.t_transaction.fee_relationship.fee_percent

    return nil if percent == 0
    return percent unless humanized
    number_to_percentage percent * 100, precision: 0
  end

  def invoice_payment_processor_fee(invoice = @invoice, humanized = true)
    fee = invoice.item_amount - invoice.payout.amount

    return fee unless humanized
    render_money fee
  end

  def invoice_hcb_revenue(invoice = @invoice, humanized = true)
    revenue = invoice.item_amount * invoice.payout.t_transaction.fee_relationship.fee_percent

    return revenue unless humanized
    render_money revenue
  end

  def invoice_hcb_profit(invoice = @invoice, humanized = true)
    profit = invoice_hcb_revenue(invoice, false) - invoice_payment_processor_fee(invoice, false)

    return profit unless humanized
    render_money profit
  end

  def invoice_event_profit(invoice = @invoice, humanized = true)
    profit = invoice.item_amount * (1 - invoice.payout.t_transaction.fee_relationship.fee_percent)

    return profit unless humanized
    render_money profit
  end
end
