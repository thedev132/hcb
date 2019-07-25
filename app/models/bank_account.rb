class BankAccount < ApplicationRecord
  has_many :transactions

  scope :syncing, -> { where(should_sync: true) }

  def balance
    self.transactions.sum(:amount)
  end
end
