# frozen_string_literal: true

class IncreaseCheckPolicy < ApplicationPolicy
  def new?
    admin_or_user?
  end

  def create?
    user_who_can_transfer? && !record.event.outernet_guild?
  end

  def approve?
    user&.admin?
  end

  def reject?
    user&.admin?
  end

  private

  def admin_or_user?
    user&.admin? || record.event.users.include?(user)
  end

  def user_who_can_transfer?
    user&.admin? || EventPolicy.new(user, record.event).new_transfer?
  end

end
