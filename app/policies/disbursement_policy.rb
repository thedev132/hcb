class DisbursementPolicy < ApplicationPolicy
  def index?
    user.admin? || record.event.users.include?(user)
  end

  def show?
    user.admin? || record.event.users.include?(user)
  end

  def new?
    user.admin? || record.event.users.include?(user)
  end

  def create?
    user.admin? || record.event.users.include?(user)
  end

  def edit?
    user.admin? || record.event.users.include?(user)
  end

  def update?
    user.admin? || record.event.users.include?(user)
  end

  def mark_fulfilled?
    user.admin? || record.event.users.include?(user)
  end

  def reject?
    user.admin? || record.event.users.include?(user)
  end

  def pending_disbursements?
    user.admin?
  end
end
