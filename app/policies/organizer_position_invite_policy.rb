class OrganizerPositionInvitePolicy < ApplicationPolicy
  def new?
    user.admin? || record.event&.users&.include?(user)
  end

  def create?
    user.admin? || record.event.users.include?(user)
  end

  def show?
    record.user == user
  end

  def accept?
    record.user == user
  end

  def reject?
    record.user == user
  end
end
