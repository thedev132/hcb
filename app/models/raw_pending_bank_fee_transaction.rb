class RawPendingBankFeeTransaction < ApplicationRecord
  monetize :amount_cents

  def date
    date_posted
  end

  def memo
    "BANK FEE".strip.upcase
  end

  def likely_event_id
    @likely_event_id ||= bank_fee.event.id
  end

  def bank_fee
    @bank_fee ||= ::BankFee.find_by(id: bank_fee_transaction_id)
  end
end
