class GSuiteAccountPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def create?
    user.admin? || record.g_suite.event.users.include?(user)
  end

  def show?
    user.admin? || record.event.users.include?(user)
  end

  def update?
    user.admin?
  end
end
