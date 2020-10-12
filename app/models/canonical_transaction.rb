class CanonicalTransaction < ApplicationRecord
  scope :exclude, -> (ids) { where('id not in (?)', ids.blank? ? [0] : ids) }
  scope :likely_github, -> { where("memo ilike '%github grant%'") }

  monetize :amount_cents

  has_many :canonical_hashed_mappings
  has_many :hashed_transactions, through: :canonical_hashed_mappings
end
