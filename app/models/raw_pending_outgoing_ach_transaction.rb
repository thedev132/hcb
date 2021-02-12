class RawPendingOutgoingAchTransaction < ApplicationRecord
  monetize :amount_cents

  def date
    date_posted
  end

  def memo
    "ACH TRANSFER #{raw_name}".strip.upcase
  end

  def likely_event_id
    @likely_event_id ||= ach_transfer.event.id
  end

  def ach_transfer
    @ach_transfer ||= ::AchTransfer.find_by(id: ach_transaction_id)
  end

  private

  def raw_name
    ach_transfer.recipient_name
  end
end
