# frozen_string_literal: true

class IncreaseCheckPolicy < ApplicationPolicy
  def new?
    admin_or_user
  end

  def create?
    admin_or_user
  end

  def approve?
    user&.admin?
  end

  def reject?
    user&.admin?
  end

  private

  def admin_or_user
    user&.admin? || record.event.users.include?(user)
  end

end
