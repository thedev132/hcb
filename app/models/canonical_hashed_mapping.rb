class CanonicalHashedMapping < ApplicationRecord
  belongs_to :canonical_transaction
  belongs_to :hashed_transaction
end
