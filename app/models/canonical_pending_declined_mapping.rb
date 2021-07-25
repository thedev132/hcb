# frozen_string_literal: true

class CanonicalPendingDeclinedMapping < ApplicationRecord
  belongs_to :canonical_pending_transaction
end
