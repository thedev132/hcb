# frozen_string_literal: true

class StripeCardPolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def shipping?
    user&.admin? || record&.event&.users&.include?(user) || record&.user == user
  end

  def freeze?
    admin_or_manager? || record&.user == user
  end

  def defrost?
    admin_or_manager? || record&.user == user
  end

  def activate?
    admin_or_manager? || record&.user == user
  end

  def show?
    user&.admin? || record&.event&.users&.include?(user) || record&.user == user
  end

  def edit?
    admin_or_manager? || record&.user == user
  end

  def update?
    admin_or_manager? || record&.user == user
  end

  def transactions?
    user&.admin? || record&.event&.users&.include?(user) || record&.user == user
  end

  alias_method :update_name?, :update?

  private

  def admin_or_manager?
    user&.admin? || OrganizerPosition.find_by(user:, event: record.event)&.manager?
  end

end
