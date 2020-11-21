class HashedTransaction < ApplicationRecord
  belongs_to :raw_csv_transaction, optional: true
  belongs_to :raw_plaid_transaction, optional: true
  belongs_to :raw_emburse_transaction, optional: true
  belongs_to :raw_stripe_transaction, optional: true

  has_one :canonical_hashed_mapping
  has_one :canonical_transaction, through: :canonical_hashed_mapping

  belongs_to :duplicate_of_hashed_transaction, class_name: "HashedTransaction", optional: true
  has_many   :duplicate_hashed_transactions, class_name: "HashedTransaction", foreign_key: "duplicate_of_hashed_transaction_id"

  scope :marked_duplicate, -> { where.not(hashed_transaction_id: nil) }

  def date
    raw_plaid_transaction.try(:date_posted) ||
      raw_emburse_transaction.try(:date_posted)
  end

  def memo
    raw_plaid_transaction.try(:memo) ||
      raw_emburse_transaction.try(:memo)
  end

  def amount_cents
    raw_plaid_transaction.try(:amount_cents) ||
      raw_emburse_transaction.try(:amount_cents)
  end
end
