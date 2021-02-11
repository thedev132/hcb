class RawPendingOutgoingCheckTransaction < ApplicationRecord
  monetize :amount_cents

  def date
    date_posted
  end

  def memo
    "CHECK TO #{raw_name} #{raw_memo}".strip.upcase
  end

  def check_number
    check.check_number || "-----"
  end

  def likely_event_id
    @likely_event_id ||= check.event.id
  end

  def check
    @check ||= ::Check.find_by(id: check_transaction_id)
  end

  private

  def raw_memo
    check.memo
  end

  def raw_name
    check.lob_address.name
  end
end
