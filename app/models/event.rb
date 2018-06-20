class Event < ApplicationRecord
  has_many :fee_relationships
  has_many :transactions, through: :fee_relationships, source: :t_transaction

  has_many :sponsors

  validates :name, :start, :end, :address, :sponsorship_fee, presence: true

  def balance
    self.transactions.sum(:amount)
  end

  def billed_transactions
    self.transactions
        .joins(:fee_relationship)
        .where(fee_relationships: { fee_applies: true } )
  end

  def fee_payments
    self.transactions
        .joins(:fee_relationship)
        .where(fee_relationships: { is_fee_payment: true } )
  end

  # total amount over all time paid agains the fee
  def fee_paid
    # fee payments are withdrawals, so negate value
    -self.fee_payments.sum(:amount)
  end

  def fee_balance
    total_fees = self.fee_relationships.sum(:fee_amount)
    total_payments = self.fee_paid

    total_fees - total_payments
  end
end
