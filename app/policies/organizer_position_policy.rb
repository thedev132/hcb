class OrganizerPositionPolicy < ApplicationPolicy
  def destroy?
    user.admin?
  end
end
