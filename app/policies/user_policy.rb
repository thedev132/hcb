class UserPolicy < ApplicationPolicy
  def edit?
    user.admin? || record == user
  end

  def update?
    user.admin? || record == user
  end

  def delete_profile_picture?
    user.admin? || record == user
  end
end
