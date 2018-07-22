class UserPolicy < ApplicationPolicy
  def edit?
    user.admin? || record == user
  end

  def update?
    user.admin? || record == user
  end
end
