# frozen_string_literal: true

class RawPendingIncomingDisbursementTransaction < ApplicationRecord
  monetize :amount_cents

  has_one :canonical_pending_transaction
  belongs_to :disbursement

  def date
    disbursement.fulfilled_at
  end

  def memo
    "Incoming Transfer".strip.upcase
  end

  def likely_event_id
    @likely_event_id ||= disbursement.destination_event.id
  end

end
