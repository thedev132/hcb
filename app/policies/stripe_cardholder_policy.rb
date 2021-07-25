# frozen_string_literal: true

class StripeCardholderPolicy < ApplicationPolicy
  def new?
    user&.admin? || record&.user = user
  end

  def create?
    user&.admin? || record&.user = user
  end

  def update?
    user&.admin? || record&.event&.users&.include?(user)
  end

  def update_profile?
    user&.admin? || record&.user == user
  end
end
