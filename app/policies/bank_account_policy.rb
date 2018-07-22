class BankAccountPolicy < ApplicationPolicy
  def new?
    bank_account_does_not_exist && user.admin?
  end

  def create?
    bank_account_does_not_exist && user.admin?
  end

  def show?
    user.admin?
  end

  private

  def bank_account_does_not_exist
    BankAccount.instance.nil?
  end
end
