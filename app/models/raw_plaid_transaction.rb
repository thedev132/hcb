class RawPlaidTransaction < ApplicationRecord
  monetize :amount_cents

  def memo
    @memo ||= plaid_transaction['name']
  end
end
