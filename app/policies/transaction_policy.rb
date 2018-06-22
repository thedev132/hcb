class TransactionPolicy < ApplicationPolicy
  def update?
    user&.admin?
  end
end
