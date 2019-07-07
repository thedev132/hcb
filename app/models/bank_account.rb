class BankAccount < ApplicationRecord
  has_many :transactions

  def balance
    self.transactions.sum(:amount)
  end
end
