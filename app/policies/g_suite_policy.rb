# frozen_string_literal: true

class GSuitePolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def create?
    user.admin?
  end

  def show?
    user.admin? || record.event.users.include?(user)
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

  def status?
    user.admin? || record.event.users.include?(user)
  end
end
