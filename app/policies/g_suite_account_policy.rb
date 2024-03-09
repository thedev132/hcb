# frozen_string_literal: true

class GSuiteAccountPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def create?
    admin_or_manager?
  end

  def show?
    user.admin? || record.event.users.include?(user)
  end

  def reset_password?
    admin_or_manager?
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

  def reject?
    user.admin?
  end

  def toggle_suspension?
    admin_or_manager?
  end

  private

  def admin_or_manager?
    user&.admin? || OrganizerPosition.find_by(user, event: record.event)&.manager?
  end

end
