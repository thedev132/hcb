# frozen_string_literal: true

class CheckDepositPolicy < ApplicationPolicy
  def index?
    admin_or_user
  end

  def create?
    !record.event.demo_mode? && !record.event.outernet_guild? && admin_or_user
  end

  private

  def admin_or_user
    user&.admin? || record.event.users.include?(user)
  end

end
