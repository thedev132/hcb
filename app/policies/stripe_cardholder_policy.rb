class StripeCardholderPolicy < ApplicationPolicy
  def new?
    user&.admin? || record&.user = user
  end

  def create?
    user&.admin? || record&.user = user
  end
end