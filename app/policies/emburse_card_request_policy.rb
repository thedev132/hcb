# frozen_string_literal: true

class EmburseCardRequestPolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def show?
    user&.admin?
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
