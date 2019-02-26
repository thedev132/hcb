class OrganizerPositionInvitePolicy < ApplicationPolicy
  def index?
    user.admin? || record.event&.users&.include?(user)
  end

  def new?
    user.admin? || record.event&.users&.include?(user)
  end

  def create?
    user.admin? || record.event.users.include?(user)
  end

  def show?
    record.user == user || user.admin?
  end

  def new?
    record.event&.users&.include?(user) || user.admin?
  end

  def accept?
    record.user == user
  end

  def reject?
    record.user == user
  end

  def cancel?
    user.admin? || record.event.users.include?(user)
  end
end
