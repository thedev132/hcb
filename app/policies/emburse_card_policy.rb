# frozen_string_literal: true

class EmburseCardPolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def show?
    record.event.users.include?(user) || user&.admin?
  end

  def edit?
    user&.admin?
  end

  def update?
    user&.admin?
  end

  def destroy?
    user&.admin?
  end
end
