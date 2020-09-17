class CanonicalEventMapping < ApplicationRecord
  belongs_to :canonical_transaction
  belongs_to :event
end
