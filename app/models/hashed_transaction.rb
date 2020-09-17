class HashedTransaction < ApplicationRecord
  belongs_to :raw_plaid_transaction, optional: true
  belongs_to :raw_emburse_transaction, optional: true

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
