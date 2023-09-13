# frozen_string_literal: true

class StripeCardPolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def shipping?
    user&.admin? || record&.event&.users&.include?(user) || record&.user == user
  end

  def freeze?
    user&.admin? || record&.event&.users&.include?(user) || record&.user == user
  end

  def defrost?
    user&.admin? || record&.event&.users&.include?(user) || record&.user == user
  end

  def activate?
    user&.admin? || record&.event&.users&.include?(user) || record&.user == user
  end

  def show?
    user&.admin? || record&.event&.users&.include?(user) || record&.user == user
  end

  def edit?
    user&.admin? || record&.event&.users&.include?(user) || record&.user == user
  end

  def update?
    user&.admin? || record&.event&.users&.include?(user) || record&.user == user
  end

  def transactions?
    user&.admin? || record&.event&.users&.include?(user) || record&.user == user
  end

  alias_method :update_name?, :update?

end
