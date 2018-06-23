class TransactionPolicy < ApplicationPolicy
  def show?
    user.admin? || record&.event&.users&.include?(user)
  end

  def edit?
    user.admin?
  end

  def update?
    user.admin?
  end
end
