class RawPendingOutgoingCheckTransaction < ApplicationRecord
  monetize :amount_cents

  def date
    date_posted
  end

  def memo
    "CHECK #{check_number} TO #{raw_name} #{raw_memo}".strip.upcase
  end

  def likely_event_id
    @likely_event_id ||= ::Check.find_by(lob_id: lob_transaction_id).try(:event).try(:id)
  end

  def check_number
    lob_transaction.dig("check_number")
  end
 
  private

  def raw_memo
    lob_transaction.dig("memo")
  end

  def raw_name
    lob_transaction.dig("to", "name")
  end
end
