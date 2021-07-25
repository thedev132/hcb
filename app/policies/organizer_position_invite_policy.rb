# frozen_string_literal: true

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
    record.email == user.email || user.admin?
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
