class Event < ApplicationRecord
  has_many :fee_relationships
  has_many :transactions, through: :fee_relationships, source: :t_transaction

  def balance
    self.transactions.sum(:amount)
  end
end
