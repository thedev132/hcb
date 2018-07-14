class DocumentPolicy < ApplicationPolicy
  def new?
    user.admin? || record.event.users.include?(user)
  end

  def create?
    user.admin? || record.event.users.include?(user)
  end

  def show?
    user.admin? || record.event.users.include?(user)
  end

  def edit?
    user.admin? || (record.user == user)
  end

  def update?
    user.admin? || (record.user == user)
  end

  def destroy?
    user.admin? || (record.user == user)
  end
end
