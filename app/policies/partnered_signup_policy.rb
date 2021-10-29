# frozen_string_literal: true

class PartneredSignupPolicy < ApplicationPolicy
  def edit?
    true
  end

  def update?
    true
  end

  def admin_accept?
    user&.admin?
  end

  def admin_reject?
    user&.admin?
  end
end
