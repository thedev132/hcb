# frozen_string_literal: true

class GrantPolicy < ApplicationPolicy
  def index?
    record.is_public? || user&.admin? || record.users.include?(user)
  end

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

  def additional_info_needed?
    user&.admin?
  end

  def show?
    user&.admin? || user == record.recipient
  end

  def activate?
    user&.admin? || user == record.recipient
  end

  private

  def admin_or_user
    user&.admin? || record.event.users.include?(user)
  end


end
