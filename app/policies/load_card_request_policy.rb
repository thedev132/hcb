class LoadCardRequestPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def new?
    record.card.event.users.include?(user) || user.admin?
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

  def reject?
    user.admin?
  end

  def cancel?
    record.creator == user
  end

  def accept?
    user.admin?
  end

  def reject?
    user.admin?
  end
end
