# frozen_string_literal: true

class RawPendingOutgoingDisbursementTransaction < ApplicationRecord
  monetize :amount_cents

  has_one :canonical_pending_transaction
  belongs_to :disbursement

  def date
    disbursement.fulfilled_at
  end

  def memo
    "Outgoing Transfer".strip.upcase
  end

  def likely_event_id
    @likely_event_id ||= disbursement.source_event.id
  end

end
