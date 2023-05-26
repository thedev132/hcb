# frozen_string_literal: true

class CardGrantPolicy < ApplicationPolicy
  def new?
    admin_or_user
  end

  def create?
    admin_or_user
  end

  def show?
    record.user == user
  end

  def activate?
    record.user == user
  end

  def admin_or_user
    user&.admin? || record.event.users.include?(user)
  end

end
