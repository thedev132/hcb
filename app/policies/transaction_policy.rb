class TransactionPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def export?
    user.admin? ||
      record.all? { |r| r.event.users.include? user }
  end

  def show?
    admin_or_teammember
  end

  def edit?
    admin_or_teammember
  end

  def update?
    admin_or_teammember
  end

  def admin_or_teammember
    user.admin? || record&.event&.users&.include?(user)
  end
end
