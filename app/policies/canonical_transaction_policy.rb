class CanonicalTransactionPolicy < ApplicationPolicy
  def show?
    admin_or_teammember
  end

  private

  def admin_or_teammember
    user&.admin? || record&.event&.users&.include?(user)
  end
end
