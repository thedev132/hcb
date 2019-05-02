module InvoicesHelper
  def invoice_hcb_percent(invoice)
    percent = invoice.payout.t_transaction.fee_relationship.fee_percent * 100

    unless percent == 0
      number_to_percentage invoice.payout.t_transaction.fee_relationship.fee_percent * 100, precision: 0
    end
  end

  def invoice_payment_processor_fee(invoice)
    render_money invoice.item_amount - invoice.payout.amount
  end

  def invoice_hcb_revenue(invoice)
    render_money invoice.item_amount * invoice.payout.t_transaction.fee_relationship.fee_percent
  end

  def invoice_hcb_profit(invoice)
    payment_processor_fee = invoice.item_amount - invoice.payout.t_transaction.amount
    revenue = invoice.item_amount * invoice.payout.t_transaction.fee_relationship.fee_percent

    render_money revenue - payment_processor_fee
  end

  def invoice_event_profit(invoice)
    t = invoice.payout.t_transaction
    percent = 1 - t.fee_relationship.fee_percent

    render_money invoice.item_amount * percent
  end
end
