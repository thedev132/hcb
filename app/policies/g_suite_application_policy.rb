class GSuiteApplicationPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def accept?
    user.admin?
  end

  def reject?
    user.admin?
  end

  def new?
    user.admin? || record.event.users.include?(user)
  end

  def create?
    user.admin? || record.event.users.include?(user)
  end

  def show?
    user.admin? || record.event.users.include?(user)
  end

  def update?
    user.admin? || record.event.users.include?(user)
  end

  def destroy?
    user.admin? || record.event.users.include?(user)
  end
end
