class HashedTransaction < ApplicationRecord
  monetize :amount_cents

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
    self[:date] || determine_store_and_return_date
  end

  def memo
    raw_plaid_transaction.try(:memo) ||
      raw_emburse_transaction.try(:memo) ||
      raw_stripe_transaction.try(:memo) || 
      raw_csv_transaction.try(:memo)
  end

  def amount_cents
    raw_plaid_transaction.try(:amount_cents) ||
      raw_emburse_transaction.try(:amount_cents) ||
      raw_stripe_transaction.try(:amount_cents) ||
      raw_csv_transaction.try(:amount_cents)
  end

  def unique_bank_identifier
    self[:unique_bank_identifier] || parse_store_and_return_unique_bank_identifier
  end

  private

  def determine_store_and_return_date
    d = raw_plaid_transaction.try(:date_posted) ||
      raw_emburse_transaction.try(:date_posted) ||
      raw_stripe_transaction.try(:date_posted) ||
      raw_csv_transaction.try(:date_posted)

    self.update_column(:date, d)

    d
  end

  def parse_store_and_return_unique_bank_identifier
    ubi = parse_unique_bank_identifier
    self.update_column(:unique_bank_identifier, ubi)

    ubi
  end

  def parse_unique_bank_identifier
    CSV.parse(primary_hash_input)[0][0]
  end
end
