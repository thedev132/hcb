# frozen_string_literal: true

class StripeAuthorizationPolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def show?
    user&.admin? || record&.event&.users&.include?(user)
  end
end
