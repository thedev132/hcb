class CanonicalPendingTransaction < ApplicationRecord
  belongs_to :raw_pending_stripe_transaction, optional: true

  monetize :amount_cents
end
