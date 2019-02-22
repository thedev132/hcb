class EventPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def new?
    user.admin?
  end

  def create?
    user.admin?
  end

  def show?
    record.users.include?(user) || user.admin?
  end

  def edit?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def team?
    user.admin? || record.users.include?(user)
  end

  def card_overview?
    user.admin? || record.users.include?(user)
  end

  def g_suite_overview?
    user.admin? || record.users.include?(user)
  end
end
