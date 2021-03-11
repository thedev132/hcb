class CanonicalPendingTransactionPolicy < ApplicationPolicy
  def show?
    admin_or_teammember
  end

  def admin_or_teammember
    user&.admin? || record&.event&.users&.include?(user)
  end
end
