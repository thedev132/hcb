# frozen_string_literal: true

class EmburseCardRequestPolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def show?
    user&.admin?
  end

  def edit?
    user&.admin?
  end

  def update?
    user&.admin?
  end

  def destroy?
    admin_or_user
  end

  def accept?
    user&.admin?
  end

  def reject?
    user&.admin?
  end

  def cancel?
    record.creator == user || user&.admin?
  end

  def export?
    user&.admin?
  end

  private

  def admin_or_user
    user&.admin? || user&.events&.include?(record.event)
  end

  def is_public
    record&.event&.is_public?
  end
end
