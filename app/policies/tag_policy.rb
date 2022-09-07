# frozen_string_literal: true

class TagPolicy < ApplicationPolicy
  def create?
    user&.admin? || record.users.include?(user)
  end

  def destroy?
    user&.admin? || record.event.users.include?(user)
  end

  def toggle_tag?
    user&.admin? || record.event.users.include?(user)
  end

end
