class CanonicalPendingEventMapping < ApplicationRecord
  belongs_to :canonical_pending_transaction
  belongs_to :event
end
