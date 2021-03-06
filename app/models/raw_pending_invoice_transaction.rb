class RawPendingInvoiceTransaction < ApplicationRecord
  monetize :amount_cents

  def date
    date_posted
  end

  def memo
    "INVOICE".strip.upcase
  end

  def likely_event_id
    @likely_event_id ||= invoice.event.id
  end

  def invoice
    @invoice ||= ::Invoice.find_by(id: invoice_transaction_id)
  end
end
