# frozen_string_literal: true

class PartneredSignupPolicy < ApplicationPolicy
  def edit?
    true
  end

  def update?
    true
  end

  def partnered_signups_accept?
    user&.admin?
  end

  def partnered_signups_reject?
    user&.admin?
  end
end
