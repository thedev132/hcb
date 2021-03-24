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
end
