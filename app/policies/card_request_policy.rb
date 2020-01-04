class CardRequestPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def new?
    record.event.users.include?(user) || user.admin?
  end

  def create?
    record.creator == user || user.admin?
  end

  def show?
    user.admin?
  end

  def edit?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.events.include?(record.event) || user.admin?
  end

  def accept?
    user.admin?
  end

  def reject?
    user.admin?
  end

  def cancel?
    record.creator == user || user.admin?
  end

  def export?
    user.admin?
  end
end
