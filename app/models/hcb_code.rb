# frozen_string_literal: true

class HcbCode < ApplicationRecord
  include Commentable
  include Receiptable

  def canonical_pending_transactions
    CanonicalPendingTransaction.where(hcb_code: hcb_code)
  end

  def canonical_transactions
    CanonicalTransaction.where(hcb_code: hcb_code)
  end

  def event
    canonical_pending_transactions.try(:first).try(:event).try(:id) || canonical_transactions.try(:first).try(:event).try(:id)
  end
end
