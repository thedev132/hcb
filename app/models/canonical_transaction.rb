class CanonicalTransaction < ApplicationRecord
  scope :likely_github, -> { where("memo ilike '%github grant%'") }

  scope :unmapped, -> { includes(:canonical_event_mapping).where(canonical_event_mappings: {canonical_transaction_id: nil}) }

  monetize :amount_cents

  has_many :canonical_hashed_mappings
  has_many :hashed_transactions, through: :canonical_hashed_mappings
  has_one :canonical_event_mapping
  has_one :event, through: :canonical_event_mapping


  # DEPRECATED
  def display_name
    memo
  end

  def filter_data
    {} # TODO
  end

  def comments
    [] # TODO
  end
end
