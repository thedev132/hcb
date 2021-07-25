# frozen_string_literal: true

class CanonicalPendingSettledMapping < ApplicationRecord
  belongs_to :canonical_pending_transaction
  belongs_to :canonical_transaction
end
