class StripeCardPolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def show?
    user&.admin? || record&.event&.users&.include?(user)
  end

  def new?
    user&.admin? || record&.event&.users&.include?(user)
  end

  def create?
    user&.admin? || record&.event&.users&.include?(user)
  end
end