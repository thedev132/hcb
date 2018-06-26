class CardRequestPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def new?
    record.user == user || user.admin?
  end

  def create?
    record.user == user || user.admin?
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
    user.admin?
  end

  def accept?
    user.admin?
  end

  def reject?
    user.admin?
  end
end
