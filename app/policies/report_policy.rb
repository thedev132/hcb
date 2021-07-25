# frozen_string_literal: true

class ReportPolicy < ApplicationPolicy
  def fees?
    admin_or_teammember
  end

  def admin_or_teammember
    user&.admin? || record&.users&.include?(user)
  end
end
