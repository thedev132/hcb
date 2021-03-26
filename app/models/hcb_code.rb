# frozen_string_literal: true

class HcbCode < ApplicationRecord
  include Hashid::Rails

  include Commentable
  include Receiptable

  monetize :amount_cents

  def amount_cents
    @amount_cents ||= begin
      return canonical_transactions.sum(:amount_cents) if canonical_transactions.exists?

      canonical_pending_transactions.sum(:amount_cents)
    end
  end

  def canonical_pending_transactions
    CanonicalPendingTransaction.where(hcb_code: hcb_code)
  end

  def canonical_transactions
    CanonicalTransaction.where(hcb_code: hcb_code)
  end

  def event
    @event ||= canonical_pending_transactions.try(:first).try(:event) || canonical_transactions.try(:first).try(:event)
  end
end
