class StripeCardholderPolicy < ApplicationPolicy
  def new?
    user&.admin? || record&.event&.users&.include?(user)
  end

  def create?
    user&.admin? || record&.event&.users&.include?(user)
  end
end