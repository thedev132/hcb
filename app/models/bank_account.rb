class BankAccount < ApplicationRecord
  def self.instance
    BankAccount.first
  end

  has_many :transactions

  before_create :only_one_instance_allowed

  def only_one_instance_allowed
    return if BankAccount.count == 0

    errors.add(:base, 'only one instance allowed')
    throw(:abort)
  end
end
